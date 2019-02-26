import java.io.FileInputStream;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Properties;

/**
 * Runs queries against a back-end database
 */
public class Query
{
  private String configFilename;
  private Properties configProps = new Properties();

  private String jSQLDriver;
  private String jSQLUrl;
  private String jSQLUser;
  private String jSQLPassword;

  // DB Connection
  private Connection conn;

  // Logged In User
  private String username; // customer username is unique

  /*
  TODO: storing user search iteneraries
  Idea: upon query, update a table to hold a userIDs most recent query.
  When that user wants to reserve a iten number, we just requery and grab the result with that index from the query.
  This prevents us from storing the whole table for each user.
  */
  // Canned queries
// only one query instantiated per flight service instance so i can store the username and password here!
  private static final String CHECK_USERNAME = "Select username from Users where username = ?";
  private PreparedStatement checkUserStatement;

  private static final String INSERT_USER = "INSERT INTO Users VALUES(?,?,?)";
  private PreparedStatement insertUserStatement;

  private static final String CHECK_FLIGHT_CAPACITY = "SELECT capacity FROM Flights WHERE fid = ?";
  private PreparedStatement checkFlightCapacityStatement;

  private static final String SEARCH_QUERY = "SELECT TOP (?) fid,year,month_id,day_of_month,carrier_id,flight_num,origin_city,actual_time,capacity,price,dest_city "
          + "FROM Flights "
          + "WHERE origin_city = ? AND dest_city = ? AND day_of_month =  ? AND canceled = 0 "
          + "ORDER BY actual_time ASC"; //TODO adjust this so that it fits actual search criteria
  private PreparedStatement safeSearchQueryStatement;

/*
Basis for one stop queries
Select DISTINCT F2.destCity as city
from allFlights as F1, allFlights as F2
where F1.ogCity = 'Seattle WA'
and F1.destCity = F2.ogCity
and F2.destCity <> 'Seattle WA'
and F2.destCity
NOT IN
  (
    Select Distinct FT.destCity from allFlights as FT
    where FT.ogCity = 'Seattle WA'
  );*/
  private static final String ONE_STOP_QUERY = "SELECT TOP (?) F1.fid,F1.flight_num,F1.year,F1.month_id,F1.day_of_month,F1.carrier_id,F1.flight_num,F1.origin_city,F1.actual_time,F1.capacity"
          + "F2.fid,F2.flight_num,F2.capacity,F2.actual_time,F2.carrier_id,F2.flightID,F2.price "
          + "FROM Flights as F1, Flights as F2 "
          + "WHERE F1.origin_city = ? AND F1.dest_city = F2.origin_city AND F2.dest_city = ? AND "
          + "F2.day_of_month=F1.day_of_month and F1.day_of_month = ? AND canceled = 0 "
          + "ORDER BY (F1.actual_time+F2.actual_time) ASC,F1.fid ASC";
  private PreparedStatement safeSearchQueryOneStopStatement;

  // transactions
  private static final String BEGIN_TRANSACTION_SQL = "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; BEGIN TRANSACTION;";
  private PreparedStatement beginTransactionStatement;

  private static final String COMMIT_SQL = "COMMIT TRANSACTION";
  private PreparedStatement commitTransactionStatement;

  private static final String ROLLBACK_SQL = "ROLLBACK TRANSACTION";
  private PreparedStatement rollbackTransactionStatement;

  class Flight
  {
    public int fid;
    public int year;
    public int monthId;
    public int dayOfMonth;
    public String carrierId;
    public String flightNum;
    public String originCity;
    public String destCity;
    public double time;
    public int capacity;
    public double price;

    @Override
    public String toString()
    {
      return "ID: " + fid + " Date: " + year + "-" + monthId + "-" + dayOfMonth + " Carrier: " + carrierId +
              " Number: " + flightNum + " Origin: " + originCity + " Dest: " + destCity + " Duration: " + time +
              " Capacity: " + capacity + " Price: " + price;
    }
  }

  public Query(String configFilename)
  {
    this.configFilename = configFilename;
  }

  /* Connection code to SQL Azure.  */
  public void openConnection() throws Exception
  {
    configProps.load(new FileInputStream(configFilename));

    jSQLDriver = configProps.getProperty("flightservice.jdbc_driver");
    jSQLUrl = configProps.getProperty("flightservice.url");
    jSQLUser = configProps.getProperty("flightservice.sqlazure_username");
    jSQLPassword = configProps.getProperty("flightservice.sqlazure_password");

		/* load jdbc drivers */
    Class.forName(jSQLDriver).newInstance();

		/* open connections to the flights database */
    conn = DriverManager.getConnection(jSQLUrl, // database
            jSQLUser, // user
            jSQLPassword); // password

    conn.setAutoCommit(true); //by default automatically commit after each statement

		/* You will also want to appropriately set the transaction's isolation level through:
		   conn.setTransactionIsolation(...)
		   See Connection class' JavaDoc for details.
		 */
  }

  public void closeConnection() throws Exception
  {
    conn.close();
  }

  /**
   * Clear the data in any custom tables created. Do not drop any tables and do not
   * clear the flights table. You should clear any tables you use to store reservations
   * and reset the next reservation ID to be 1.
   */
  public void clearTables ()
  {
    // your code here
  }

	/**
   * prepare all the SQL statements in this method.
   * "preparing" a statement is almost like compiling it.
   * Note that the parameters (with ?) are still not filled in
   */
  public void prepareStatements() throws Exception
  {
    beginTransactionStatement = conn.prepareStatement(BEGIN_TRANSACTION_SQL);
    commitTransactionStatement = conn.prepareStatement(COMMIT_SQL);
    rollbackTransactionStatement = conn.prepareStatement(ROLLBACK_SQL);

    checkFlightCapacityStatement = conn.prepareStatement(CHECK_FLIGHT_CAPACITY);
    //the below handle our search queries.
    safeSearchQueryStatement = conn.prepareStatement(SEARCH_QUERY);
    safeSearchQueryOneStopStatement = conn.prepareStatement(ONE_STOP_QUERY);
    //the below handle creating a new customer account
    insertUserStatement = conn.prepareStatement(INSERT_USER);
    checkUserStatement = conn.prepareStatement(CHECK_USERNAME);

    /* add here more prepare statements for all the other queries you need */
		/* . . . . . . */
  }

  /**
   * Takes a user's username and password and attempts to log the user in.
   *
   * @param username
   * @param password
   *
   * @return If someone has already logged in, then return "User already logged in\n"
   * For all other errors, return "Login failed\n".
   *
   * Otherwise, return "Logged in as [username]\n".
   */
  public String transaction_login(String username, String password)
  {
    return "Login failed\n";
  }

  /**
   * Implement the create user function.
   *
   * @param username new user's username. User names are unique the system.
   * @param password new user's password.
   * @param initAmount initial amount to deposit into the user's account, should be >= 0 (failure otherwise).
   *
   * @return either "Created user {@code username}\n" or "Failed to create user\n" if failed.
   */
   //how do we handle throw exception within flight service? do we need t
  public String transaction_createCustomer (String username, String password, double initAmount)
  {
    ResultSet userResult = null;
    int success = 0;
    if(initAmount<0)
    {
      return "Invalid Input: Can't create customer";
    }
    try{
      beginTransaction();
      checkUserStatement.clearParameters();
      checkUserStatement.setString(1,username);
      userResult = checkUserStatement.executeQuery();
      commitTransaction();
      if(userResult.next())
      {
        userResult.close();
        return "Invalid Input: Username already exists";
      }
      success=0;
      beginTransaction();
      insertUserStatement.clearParameters();
      insertUserStatement.setString(1,username);
      insertUserStatement.setString(2,password);
      insertUserStatement.setDouble(3,initAmount);
      success= insertUserStatement.executeUpdate();
      commitTransaction();
  }
  catch(SQLException e) {e.printStackTrace();}
  finally {
    if (userResult != null) {
      try {
        userResult.close();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  return "Customer sucessfully added!";
}

  /**
   * Implement the search function.
   *
   * Searches for flights from the given origin city to the given destination
   * city, on the given day of the month. If {@code directFlight} is true, it only
   * searches for direct flights, otherwise is searches for direct flights
   * and flights with two "hops." Only searches for up to the number of
   * itineraries given by {@code numberOfItineraries}.
   *
   * The results are sorted based on total flight time.
   *
   * @param originCity
   * @param destinationCity
   * @param directFlight if true, then only search for direct flights, otherwise include indirect flights as well
   * @param dayOfMonth
   * @param numberOfItineraries number of itineraries to return
   *
   * @return If no itineraries were found, return "No flights match your selection\n".
   * If an error occurs, then return "Failed to search\n".
   *
   * Otherwise, the sorted itineraries printed in the following format:
   *
   * Itinerary [itinerary number]: [number of flights] flight(s), [total flight time] minutes\n
   * [first flight in itinerary]\n
   * ...
   * [last flight in itinerary]\n
   *
   * Each flight should be printed using the same format as in the {@code Flight} class. Itinerary numbers
   * in each search should always start from 0 and increase by 1.
   *
   * @see Flight#toString()
   Flight: 2015,7,14,B6,1698,Seattle WA,294Flight: 2015,7,14,B6,498,Seattle WA,304Flight: 2005,7,14,AS,24,Seattle WA,308Flight: 2015,7,14,B6,998,Seattle WA,313Flight: 2015,7,14,AS,734,Seattle WA,315Flight: 2005,7,14,AS,12,Seattle WA,316Flight: 2015,7,14,AS,24,Seattle WA,319Flight: 2015,7,14,AS,12,Seattle WA,324Flight: 2015,7,14,B6,598,Seattle WA,340
   Flight: 2015,7,14,B6,1698,Seattle WA,294Flight: 2015,7,14,B6,498,Seattle WA,304Flight: 2005,7,14,AS,24,Seattle WA,308Flight: 2015,7,14,B6,998,Seattle WA,313Flight: 2015,7,14,AS,734,Seattle WA,315Flight: 2005,7,14,AS,12,Seattle WA,316Flight: 2015,7,14,AS,24,Seattle WA,319Flight: 2015,7,14,AS,12,Seattle WA,324Flight: 2015,7,14,B6,598,Seattle WA,340
   */
  public String transaction_search(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries)
  {
    try{
      return safeFlightQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries);
    }
    catch(SQLException e){ e.printStackTrace();}
    return("invalid sql query!");
  }

  /**
   * Same as {@code transaction_search} except that it only performs single hop search and
   * do it in an unsafe manner.
   *
   * @param originCity
   * @param destinationCity
   * @param directFlight
   * @param dayOfMonth
   * @param numberOfItineraries
   *
   * @return The search results. Note that this implementation *does not conform* to the format required by
   * {@code transaction_search}.
   */
  private String transaction_search_unsafe(String originCity, String destinationCity, boolean directFlight,
                                          int dayOfMonth, int numberOfItineraries)
  {
    StringBuffer sb = new StringBuffer();

    try
    {
      // one hop itineraries
      String unsafeSearchSQL =
              "SELECT TOP (" + numberOfItineraries + ") year,month_id,day_of_month,carrier_id,flight_num,origin_city,actual_time "
                      + "FROM Flights "
                      + "WHERE origin_city = \'" + originCity + "\' AND dest_city = \'" + destinationCity + "\' AND day_of_month =  " + dayOfMonth + " "
                      + "ORDER BY actual_time ASC";

      Statement searchStatement = conn.createStatement();
      ResultSet oneHopResults = searchStatement.executeQuery(unsafeSearchSQL);

      while (oneHopResults.next())
      {
        int result_year = oneHopResults.getInt("year");
        int result_monthId = oneHopResults.getInt("month_id");
        int result_dayOfMonth = oneHopResults.getInt("day_of_month");
        String result_carrierId = oneHopResults.getString("carrier_id");
        String result_flightNum = oneHopResults.getString("flight_num");
        String result_originCity = oneHopResults.getString("origin_city");
        int result_time = oneHopResults.getInt("actual_time");
        sb.append("Flight: " + result_year + "," + result_monthId + "," + result_dayOfMonth + "," + result_carrierId + "," + result_flightNum + "," + result_originCity + "," + result_time);
      }
      oneHopResults.close();
    } catch (SQLException e) { e.printStackTrace(); }

    return sb.toString();
  }

  /**
   * Implements the book itinerary function.
   *
   * @param itineraryId ID of the itinerary to book. This must be one that is returned by search in the current session.
   *
   * @return If the user is not logged in, then return "Cannot book reservations, not logged in\n".
   * If try to book an itinerary with invalid ID, then return "No such itinerary {@code itineraryId}\n".
   * If the user already has a reservation on the same day as the one that they are trying to book now, then return
   * "You cannot book two flights in the same day\n".
   * For all other errors, return "Booking failed\n".
   *
   * And if booking succeeded, return "Booked flight(s), reservation ID: [reservationId]\n" where
   * reservationId is a unique number in the reservation system that starts from 1 and increments by 1 each time a
   * successful reservation is made by any user in the system.
   */
  public String transaction_book(int itineraryId)
  {
    return "Booking failed\n";
  }

  /**
   * Implements the reservations function.
   *
   * @return If no user has logged in, then return "Cannot view reservations, not logged in\n"
   * If the user has no reservations, then return "No reservations found\n"
   * For all other errors, return "Failed to retrieve reservations\n"
   *
   * Otherwise return the reservations in the following format:
   *
   * Reservation [reservation ID] paid: [true or false]:\n"
   * [flight 1 under the reservation]
   * [flight 2 under the reservation]
   * Reservation [reservation ID] paid: [true or false]:\n"
   * [flight 1 under the reservation]
   * [flight 2 under the reservation]
   * ...
   *
   * Each flight should be printed using the same format as in the {@code Flight} class.
   *
   * @see Flight#toString()
   */
  public String transaction_reservations()
  {
    return "Failed to retrieve reservations\n";
  }

  /**
   * Implements the cancel operation.
   *
   * @param reservationId the reservation ID to cancel
   *
   * @return If no user has logged in, then return "Cannot cancel reservations, not logged in\n"
   * For all other errors, return "Failed to cancel reservation [reservationId]"
   *
   * If successful, return "Canceled reservation [reservationId]"
   *
   * Even though a reservation has been canceled, its ID should not be reused by the system.
   */
  public String transaction_cancel(int reservationId)
  {
    return "Failed to cancel reservation " + reservationId;
  }

  /**
   * Implements the pay function.
   *
   * @param reservationId the reservation to pay for.
   *
   * @return If no user has logged in, then return "Cannot pay, not logged in\n"
   * If the reservation is not found / not under the logged in user's name, then return
   * "Cannot find unpaid reservation [reservationId] under user: [username]\n"
   * If the user does not have enough money in their account, then return
   * "User has only [balance] in account but itinerary costs [cost]\n"
   * For all other errors, return "Failed to pay for reservation [reservationId]\n"
   *
   * If successful, return "Paid reservation: [reservationId] remaining balance: [balance]\n"
   * where [balance] is the remaining balance in the user's account.
   */
  public String transaction_pay (int reservationId)
  {
      return "Failed to pay for reservation " + reservationId + "\n";
  }

  /* some utility functions below */

  public void beginTransaction() throws SQLException
  {
    conn.setAutoCommit(false);
    beginTransactionStatement.executeUpdate();
  }

  public void commitTransaction() throws SQLException
  {
    commitTransactionStatement.executeUpdate();
    conn.setAutoCommit(true);
  }

  public void rollbackTransaction() throws SQLException
  {
    rollbackTransactionStatement.executeUpdate();
    conn.setAutoCommit(true);
  }

  /**
   * Shows an example of using PreparedStatements after setting arguments. You don't need to
   * use this method if you don't want to.
   */
  private int checkFlightCapacity(int fid) throws SQLException
  {
    checkFlightCapacityStatement.clearParameters();
    checkFlightCapacityStatement.setInt(1, fid);
    ResultSet results = checkFlightCapacityStatement.executeQuery();
    results.next();
    int capacity = results.getInt("capacity");
    results.close();

    return capacity;
  }

  private int oneStopFlightQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries,int numSoFar,StringBuffer sb) throws SQLException
  {
    int itenSoFar = numSoFar;
    ResultSet oneStopResults = null;
    try{
      beginTransaction();
      safeSearchQueryOneStopStatement.clearParameters();
      safeSearchQueryOneStopStatement.setInt(1,numberOfItineraries-itenSoFar);
      safeSearchQueryOneStopStatement.setString(2,originCity);
      safeSearchQueryOneStopStatement.setString(3,destinationCity);
      safeSearchQueryOneStopStatement.setInt(4,dayOfMonth);
      oneStopResults = safeSearchQueryOneStopStatement.executeQuery();
      commitTransaction();
    }
    catch(SQLException e) {e.printStackTrace();}
    while (oneStopResults.next())
    {
      int result_year = oneStopResults.getInt("F1.year");
      int result_monthId = oneStopResults.getInt("F1.month_id");
      int result_dayOfMonth = oneStopResults.getInt("F1.day_of_month");
      String result_carrierId1 = oneStopResults.getString("F1.carrier_id");
      String result_originCity1 = oneStopResults.getString("F1.origin_city");
      String result_destCity1 = oneStopResults.getString("F1.dest_city");
      double price1 = oneStopResults.getDouble("F1.price");
      int flightID1 = oneStopResults.getInt("F1.fid");
      int flightNum1 = oneStopResults.getInt("F1.flight_num");
      double result_time1 = oneStopResults.getDouble("F1.actual_time");
      int capacity1 = oneStopResults.getInt("F1.capacity");
      //now for the second item in the flight iten
      String result_carrierId2 = oneStopResults.getString("F2.carrier_id");
      String result_originCity2 = oneStopResults.getString("F2.origin_city");
      String result_destCity2 = oneStopResults.getString("F2.dest_city");
      double price2 = oneStopResults.getDouble("F2.price");
      int flightID2 = oneStopResults.getInt("F2.fid");
      int flightNum2 = oneStopResults.getInt("F2.flight_num");
      double result_time2 = oneStopResults.getDouble("F2.actual_time");
      int capacity2 = oneStopResults.getInt("F2.capacity");
      String date = result_year+"-"+result_monthId+"-"+result_dayOfMonth;
      double totalTime = result_time1+result_time2;
      sb.append("Itinerary " +itenSoFar+": 2 flight(s), " + totalTime + " minutes\n");
      sb.append("ID: " + flightID1+ " Date: " + date + " Carrier: " +result_carrierId1+" Number: "+flightNum1+" Origin: " +result_originCity1 +"\n");
      sb.append("Dest: " + result_destCity1+" Duration: " + result_time1 +" Capacity: "+ capacity1+" Price: "+price1+"\n");
      //could definetly make these string appending things a seperate function, but lets leave that for later
      sb.append("ID: " + flightID2+ " Date: " + date + " Carrier: " +result_carrierId2+" Number: "+flightNum2+" Origin: " +result_originCity2 +"\n");
      sb.append("Dest: " + result_destCity2+" Duration: " + result_time2 +" Capacity: "+ capacity2+" Price: "+price2+"\n");
      itenSoFar+=1;

    }
    oneStopResults.close();
    return itenSoFar;
  }

  private void directFlightQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries,int numSoFar,StringBuffer sb) throws SQLException
  {
    int itenSoFar = numSoFar;
    ResultSet directResults = null;
    try{
      beginTransaction();
      safeSearchQueryStatement.clearParameters();
      safeSearchQueryStatement.setInt(1,numberOfItineraries-itenSoFar);
      safeSearchQueryStatement.setString(2,originCity);
      safeSearchQueryStatement.setString(3,destinationCity);
      safeSearchQueryStatement.setInt(4,dayOfMonth);
      directResults = safeSearchQueryStatement.executeQuery();
      commitTransaction();
    }
    catch(SQLException e) {e.printStackTrace();}
    while (directResults.next())
    {
      int result_year = directResults.getInt("year");
      int result_monthId = directResults.getInt("month_id");
      int result_dayOfMonth = directResults.getInt("day_of_month");
      String result_carrierId = directResults.getString("carrier_id");
      String result_flightNum = directResults.getString("flight_num");
      String result_originCity = directResults.getString("origin_city");
      String result_destCity = directResults.getString("dest_city");
      double price = directResults.getDouble("price");
      int flightID = directResults.getInt("fid");
      int flightNum = directResults.getInt("flight_num");
      double result_time = directResults.getDouble("actual_time");
      int capacity = directResults.getInt("capacity");
      String date = result_year+"-"+result_monthId+"-"+result_dayOfMonth;
      sb.append("Itinerary " +itenSoFar+": 1 flight(s), " + result_time + " minutes\n");
      sb.append("ID: " + flightID + " Date: " + date + " Carrier: " +result_carrierId+" Number: "+flightNum+" Origin: " +result_originCity +"\n");
      sb.append("Dest: " + result_destCity+" Duration: " + result_time +" Capacity: "+ capacity+" Price: "+price+"\n");
      itenSoFar+=1;

    }

    directResults.close();
  }
  //works!!!
  private String safeFlightQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries) throws SQLException
  {
    StringBuffer sb = new StringBuffer();
    int itenSoFar = 0;
    ResultSet oneHopResults = null;
    try
    {
      // one hop itineraries
      if(directFlight)
      {
        directFlightQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries,0,sb);
        //works
        //TODO: implement and recycle code to make it work for one stop
      }
      else
      {
        itenSoFar = oneStopFlightQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries,0,sb);
      }

      if(directFlight == false && itenSoFar<=numberOfItineraries)
      {
        directFlightQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries,itenSoFar,sb);
      }
    } catch (SQLException e) { e.printStackTrace(); }

    return sb.toString();
  }

}
