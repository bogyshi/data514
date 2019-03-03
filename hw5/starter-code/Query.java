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
  private static final String LOGIN_USER = "Select username from Users where username = ? and password = ?";
  private PreparedStatement signInUserStatement;

  private static final String DROP_RESERVATION = "DELETE FROM Reservations where reservationID = ?";
  private PreparedStatement dropReservationStatement;
// only one query instantiated per flight service instance so i can store the username and password here!
  private static final String CHECK_USERNAME = "Select username from Users where username = ?";
  private PreparedStatement checkUserStatement;

  private static final String GET_USER_ACCT = "Select * from Users where username = ?";
  private PreparedStatement getUserAcctStatement;

  private static final String UPDATE_USER_ACCT = "UPDATE Users SET balance = ? where username = ?";
  private PreparedStatement updateUserAcctStatement;

  private static final String UPDATE_RESERVATION_PAID="UPDATE Reservations SET paid = ? where username = ? and reservationID = ?";
  private PreparedStatement updateReservationPaidStatement;

  private static final String INSERT_RESERVATION = "INSERT INTO Reservations VALUES(?,?,?,?,?,?)";
  private PreparedStatement insertReservationStatement;

  private static final String GET_RESERVATIONS = "Select * from Reservations where username = ? ORDER BY reservationID";
  private PreparedStatement getReservationsStatement;

  private static final String GET_RESERVATIONID = "Select * from ReservationIDCounter";
  private PreparedStatement getReservationIDStatement;

  private static final String UPDATE_RESERVATIONID = "UPDATE ReservationIDCounter SET currentIDs = ?";
  private PreparedStatement updateReservationIDStatement;

  private static final String INSERT_USER = "INSERT INTO Users VALUES(?,?,?)";
  private PreparedStatement insertUserStatement;

  private static final String INSERT_SEARCH = "INSERT INTO UserSearches VALUES(?,?,?,?,?,?)"; //TODO: how do i update several values in a table? or do i drop the row and then re add it?
  private PreparedStatement insertSearchStatement;

  private static final String GET_SEARCH = "Select * from UserSearches where username = ?";
  private PreparedStatement getSearchStatement;

  private static final String GET_FLIGHT = "Select * from Flights where fid = ?";
  private PreparedStatement getFlightStatement;

  private static final String UPDATE_CAPACITY = "UPDATE Capacities SET currentCapacity = ? where flightID = ?";
  private PreparedStatement updateCapacityStatement;

  private static final String INSERT_CAPACITY= "INSERT INTO Capacities VALUES(?,?,?)";
  private PreparedStatement insertCapacityStatement;

  private static final String GET_CAPACITY= "Select * from Capacities where flightID = ?";
  private PreparedStatement getCapacityStatement;

  private static final String DROP_SEARCH = "DELETE FROM UserSearches where username = ?";//TODO: how do i update several values in a table? or do i drop the row and then re add it?
  private PreparedStatement dropSearchStatement;

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
  private static final String ONE_STOP_QUERY = "SELECT TOP (?) F1.fid as f1id ,F1.flight_num as f1flightnum,F1.year as f1year,F1.month_id as f1month,F1.day_of_month as f1dom,F1.carrier_id as f1cid,F1.origin_city as f1oc,F1.actual_time as f1at,F1.capacity as f1c,F1.dest_city as f1dc, F1.price as f1price, "
          + "F2.fid,F2.flight_num,F2.capacity,F2.actual_time,F2.carrier_id,F2.fid,F2.price,F2.origin_city,F2.dest_city "
          + "FROM Flights F1, Flights F2 "
          + "WHERE F1.origin_city = ? AND F1.dest_city = F2.origin_city AND F2.dest_city = ? AND F1.year = F2.year AND "
          + "F2.day_of_month=F1.day_of_month and F1.day_of_month = ? AND F1.canceled = 0 AND F2.canceled = 0"
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
    signInUserStatement = conn.prepareStatement(LOGIN_USER);
    insertSearchStatement = conn.prepareStatement(INSERT_SEARCH);
    dropSearchStatement = conn.prepareStatement(DROP_SEARCH);
    insertCapacityStatement = conn.prepareStatement(INSERT_CAPACITY);
    getCapacityStatement = conn.prepareStatement(GET_CAPACITY);
    getSearchStatement = conn.prepareStatement(GET_SEARCH);
    updateCapacityStatement = conn.prepareStatement(UPDATE_CAPACITY);
    updateReservationIDStatement = conn.prepareStatement(UPDATE_RESERVATIONID);
    getReservationIDStatement = conn.prepareStatement(GET_RESERVATIONID);
    getReservationsStatement = conn.prepareStatement(GET_RESERVATIONS);
    getFlightStatement = conn.prepareStatement(GET_FLIGHT);
    insertReservationStatement = conn.prepareStatement(INSERT_RESERVATION);
    getUserAcctStatement = conn.prepareStatement(GET_USER_ACCT);
    updateUserAcctStatement = conn.prepareStatement(UPDATE_USER_ACCT);
    updateReservationPaidStatement = conn.prepareStatement(UPDATE_RESERVATION_PAID);
    dropReservationStatement = conn.prepareStatement(DROP_RESERVATION);
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
    ResultSet userResult = null;
    int success = 0;
    try{
      beginTransaction();
      signInUserStatement.clearParameters();
      signInUserStatement.setString(1,username);
      signInUserStatement.setString(2,password);
      userResult = signInUserStatement.executeQuery();
      commitTransaction();
      if(userResult.next())
      {
        userResult.close();
        this.username = username;//may need to do something here
        return "User signed in sucessfully";
      }
      success=0;
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


  private boolean checkReserveDay(int dom)
  {
    ResultSet reservs = null;
    try
    {
      beginTransaction();
      getReservationsStatement.clearParameters();
      getReservationsStatement.setString(1,username);
      reservs = getReservationsStatement.executeQuery();
      commitTransaction();
      while(reservs.next())
      {
        if(reservs.getInt("flightDay")==dom)
        {
          return false;
        }
      }
      reservs.close();
    }
    catch(SQLException e)
    {
      e.printStackTrace();
    }
    return true;
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

   username varchar(20) REFERENCES Users(username),
 	origin_city varchar(100),
 	dest_city varchar(100),
 	direct_flight bit,
 	day_of_month int,
 	num_iten int
   */
  public String transaction_book(int itineraryId)
  {
    //first, we check if the flight is in the capacity table
    if(username == null)
    {
      return("Cannot book reservations, not logged in\n");
    }
    //unusre if we have to (deal with phantomn reads and such
    ResultSet checkIten = null;
    ResultSet directResults = null;
    ResultSet oneStopResults = null;
    boolean res = false;
    String debug="whoops";
    int itenSoFar = 0;
    int flightID1 = -1;
    int flightID2 = -1;
    int cap1 = -1;
    int cap2 = -1;
    int resID = -1;
    int dom=-1;
    boolean pass = false;
    try
    {
      getSearchStatement.clearParameters();
      getSearchStatement.setString(1,username);
      checkIten = getSearchStatement.executeQuery();
      res = checkIten.next();
      if(res==false)
      {
        return "No such itinerary " + itineraryId +"\n";
      }
      String ogc = checkIten.getString("origin_city");
      String ogdc = checkIten.getString("dest_city");
      boolean df = checkIten.getBoolean("direct_flight");
      dom = checkIten.getInt("day_of_month");
      int numIten = checkIten.getInt("num_iten");
      checkIten.close();
      if(numIten <itineraryId){return "No such itinerary " + itineraryId +"\n";}
      if(checkReserveDay(dom)==false){return "You cannot book two flights in the same day\n";}
      safeSearchQueryStatement.clearParameters();
      safeSearchQueryStatement.setInt(1,numIten);
      safeSearchQueryStatement.setString(2,ogc);
      safeSearchQueryStatement.setString(3,ogdc);
      safeSearchQueryStatement.setInt(4,dom);
      directResults = safeSearchQueryStatement.executeQuery();
      while(directResults.next())
      {
        if(itenSoFar == itineraryId)
        {
          flightID1 = directResults.getInt("fid");
          cap1= directResults.getInt("capacity");
        }
        itenSoFar+=1;
      }
      directResults.close();
      if(itenSoFar<itineraryId && (df==false))
        {
        safeSearchQueryOneStopStatement.clearParameters();
        safeSearchQueryOneStopStatement.setInt(1,numIten);
        safeSearchQueryOneStopStatement.setString(2,ogc);
        safeSearchQueryOneStopStatement.setString(3,ogdc);
        safeSearchQueryOneStopStatement.setInt(4,dom);
        oneStopResults = safeSearchQueryOneStopStatement.executeQuery();
        while(oneStopResults.next())
        {
          if(itenSoFar==itineraryId)
          {
            flightID1 = oneStopResults.getInt("f1id");
            cap1=oneStopResults.getInt("f1c");
            flightID2 = oneStopResults.getInt("fid");
            cap2=oneStopResults.getInt("capacity");

          }
          itenSoFar+=1;
        }
        oneStopResults.close();
      }

      if(flightID1 >=0)
      {
        System.out.println(flightID1);
        System.out.println(flightID2);
        pass = checkCapTable(flightID1,cap1);
        if(pass && flightID2 != -1)
        {
          pass = checkCapTable(flightID2,cap2);
        }
        else if(!pass)
        {
          return("Booking failed\n");
        }
      }
    }
    catch(SQLException e) {e.printStackTrace();}
    if(!pass)
    {
      debug = "Booking failed\n";
    }
    else
    {
      resID = insertReservation(flightID1,flightID2,dom);
      debug = "Booked flight(s), reservation ID: "+resID+"\n";
    }
    //then we either add it to the table and then check capacity remaining
    //then we update the table to have one more in the capacitysofar
    //donezo kid
    return debug;
  }

  private int insertReservation(int flightID1, int flightID2, int dayOfMonth)
  {
    int tr = -1;
    int newID = -1;
    ResultSet temp = null;
    try {
    beginTransaction();
    getReservationIDStatement.clearParameters();
    temp = getReservationIDStatement.executeQuery();
    if(temp.next())
    {
      tr = temp.getInt("currentIDs");
    }
    else
    {
      return -1;
    }
    newID = tr+1;
    insertReservationStatement.clearParameters();
    insertReservationStatement.setInt(1,tr);
    insertReservationStatement.setString(2,username);
    insertReservationStatement.setInt(3,dayOfMonth);
    insertReservationStatement.setInt(4,flightID1);
    if(flightID2<0)
    {
      insertReservationStatement.setNull(5,java.sql.Types.INTEGER);
    }
    else
    {
      insertReservationStatement.setInt(5,flightID2);
    }
    insertReservationStatement.setBoolean(6,false);
    insertReservationStatement.executeUpdate();
    updateReservationIDStatement.clearParameters();
    updateReservationIDStatement.setInt(1,newID);
    updateReservationIDStatement.executeUpdate();
    temp.close();
    commitTransaction();
  }
  catch(SQLException e)
  {
    e.printStackTrace();
  }
    return tr;
  }

  private boolean checkCapTable(int flightID,int maxCap)
  {
    ResultSet checkPres = null;
    int cap =-1;
    boolean pass=false;
    System.out.println(flightID);
    System.out.println(maxCap);
    try
    {
    getCapacityStatement.clearParameters();
    getCapacityStatement.setInt(1,flightID);
    beginTransaction();
    checkPres = getCapacityStatement.executeQuery();
    if(checkPres.next())
    {
      cap = checkPres.getInt("currentCapacity");
      if(cap+1<=maxCap)
      {
        pass = true;
      }
      else
      {
        return false;
      }
      cap+=1;
      updateCapacityStatement.clearParameters();
      updateCapacityStatement.setInt(1,cap);
      updateCapacityStatement.setInt(2,flightID);
      updateCapacityStatement.executeUpdate();
    }
    else
    {
      if(maxCap == 0)
      {

      }
      else
      {
        insertCapacityStatement.clearParameters();
        insertCapacityStatement.setInt(1,flightID);
        insertCapacityStatement.setInt(2,maxCap);
        insertCapacityStatement.setInt(3,1);
        insertCapacityStatement.executeUpdate();
        pass=true;
      }
    }
    commitTransaction();
  }
  catch(SQLException e) {e.printStackTrace();}
  finally {
    if (checkPres != null) {
      try {
        checkPres.close();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
    return pass;
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
    if(username == null)
    {
      return "Cannot view reservations, not logged in\n";
    }
    StringBuffer sb = new StringBuffer();
    int numreservs = 0;

    try
    {
      ResultSet reservs=null;
      ResultSet flight1=null;
      ResultSet flight2=null;
      int flightID1 = -1;
      int flightID2 = -1;
      int resID = -1;
      int dom;
      int mid;
      String ogc;
      String dc;
      int year;
      String carrier;
      boolean paid = false;
      int flightNum;
      double price;
      double at;
      int capacity;
      getReservationsStatement.clearParameters();
      getReservationsStatement.setString(1,username);
      reservs = getReservationsStatement.executeQuery();
      while(reservs.next())
      {
        resID = reservs.getInt("reservationID");
        paid = reservs.getBoolean("paid");
        sb.append("Reservation " + resID + " paid: " + paid+":\n");
        flightID1 = reservs.getInt("flight1");
        flightID2 = reservs.getInt("flight2");
        getFlightStatement.clearParameters();
        getFlightStatement.setInt(1,flightID1);
        flight1 = getFlightStatement.executeQuery();
        if(!flight1.next())
        {
          System.out.println("wuhoh");
          return null;
        }
        year = flight1.getInt("year");
        mid = flight1.getInt("month_id");
        dom = flight1.getInt("day_of_month");
        carrier = flight1.getString("carrier_id");
        flightNum = flight1.getInt("flight_num");
        ogc = flight1.getString("origin_city");
        dc = flight1.getString("dest_city");
        price = flight1.getDouble("price");
        at = flight1.getDouble("actual_time");
        capacity = flight1.getInt("capacity");
        String date = year+"-"+mid+"-"+dom;
        sb.append("ID: " + flightID1 + " Date: " + date + " Carrier: " +carrier+" Number: "+flightNum+" Origin: " +ogc +"\n");
        sb.append("Dest: " + dc+" Duration: " + at +" Capacity: "+ capacity+" Price: "+price+"\n");
        flight1.close();
        if(flightID2>0)
        {
          getFlightStatement.clearParameters();
          getFlightStatement.setInt(1,flightID2);
          flight1 = getFlightStatement.executeQuery();
          if(!flight1.next())
          {
            System.out.println("wuhoh2");
            return null;
          }
          year = flight1.getInt("year");
          mid = flight1.getInt("month_id");
          dom = flight1.getInt("day_of_month");
          carrier = flight1.getString("carrier_id");
          flightNum = flight1.getInt("flight_num");
          ogc = flight1.getString("origin_city");
          dc = flight1.getString("dest_city");
          price = flight1.getDouble("price");
          at = flight1.getDouble("actual_time");
          capacity = flight1.getInt("capacity");
          date = year+"-"+mid+"-"+dom;
          sb.append("ID: " + flightID2 + " Date: " + date + " Carrier: " +carrier+" Number: "+flightNum+" Origin: " +ogc +"\n");
          sb.append("Dest: " + dc+" Duration: " + at +" Capacity: "+ capacity+" Price: "+price+"\n");
        }
        numreservs+=1;
      }
      reservs.close();
  }
  catch(SQLException e){e.printStackTrace();}
  if(numreservs<=0)
  {
    return "No reservations found\n";
  }
  return sb.toString();
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
    String resMessage = "Failed to cancel reservation " + reservationId;
    if(username == null)
    {
      return("Cannot cancel reservations, not logged in \n");
    }
    ResultSet reservs = null;
    ResultSet flights = null;
    boolean pass = false;
    int flightID1= 0;
    int flightID2 =0;
    double price1=0;
    double price2=0;
    boolean paid = false;
    try
    {
      beginTransaction();
      getReservationsStatement.clearParameters();
      getReservationsStatement.setString(1,username);
      reservs = getReservationsStatement.executeQuery();
      while(reservs.next())
      {
        if(reservs.getInt("reservationID")==reservationId)
        {
          paid = reservs.getBoolean("paid");
          flightID1 = reservs.getInt("flight1");
          flightID2 = reservs.getInt("flight2");
          if(paid)
          {
            getFlightStatement.clearParameters();
            getFlightStatement.setInt(1,flightID1);
            flights = getFlightStatement.executeQuery();
            if(flights.next())
            {
              price1 = flights.getDouble("price");
              pass=true;
            }
            if(pass && flightID2>0)
            {
              flights.close();
              getFlightStatement.clearParameters();
              getFlightStatement.setInt(1,flightID2);
              flights = getFlightStatement.executeQuery();
              if(flights.next())
              {
                price2 = flights.getDouble("price");
              }
              else
              {
                pass = false;
              }
            }
          }
          break;
        }
      }
      if(reservs!=null){reservs.close();}
      if(paid && pass)
      {
        double totalCost = price1+price2;
        pass = refundReservation(totalCost,reservationId);
        if(!pass)
        {
          System.out.println("wuhoh3!");
        }
      }
      if(pass)
      {
        handleCancelation(flightID1);
        handleCancelation(flightID2);
        dropReservationStatement.clearParameters();
        dropReservationStatement.setInt(1,reservationId);
        dropReservationStatement.executeUpdate();
        resMessage = "Canceled reservation "+reservationId;
      }
      commitTransaction();

    }
    catch(SQLException e)
    {
      e.printStackTrace();
    }
    finally {
      if (flights != null) {
        try {
          flights.close();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
      if (reservs != null) {
        try {
          reservs.close();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
    //return("Canceled reservation" + reservationId);
    return resMessage;
  }

  private boolean handleCancelation(int flightID)
  {
    ResultSet checkPres = null;
    int cap =-1;
    boolean pass=false;
    try
    {
    getCapacityStatement.clearParameters();
    getCapacityStatement.setInt(1,flightID);
    checkPres = getCapacityStatement.executeQuery();
    if(checkPres.next())
    {
      cap = checkPres.getInt("currentCapacity");
      if(cap-1>=0)
      {
        pass = true;
      }
      else
      {
        return false;
      }
      cap-=1;
      updateCapacityStatement.clearParameters();
      updateCapacityStatement.setInt(1,cap);
      updateCapacityStatement.setInt(2,flightID);
      updateCapacityStatement.executeUpdate();
    }
    else
    {
      System.out.println("This really shouldnt happen ever");
    }
  }
  catch(SQLException e) {e.printStackTrace();}
  finally {
    if (checkPres != null) {
      try {
        checkPres.close();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
    return pass;
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
    if(username == null)
    {
      return("Cannot pay, not logged in\n");
    }
    String resMessage = "";
    ResultSet reservs = null;
    ResultSet flights = null;
    double price1=0;
    double price2=0;
    double[] remaining = {0,0};
    boolean pass = false;
    try
    {
      beginTransaction();//were gonna hold onto this until the very end
      getReservationsStatement.clearParameters();
      getReservationsStatement.setString(1,username);
      reservs = getReservationsStatement.executeQuery();
      while(reservs.next())
      {
        if(reservs.getInt("reservationID")==reservationId)
        {
          getFlightStatement.clearParameters();
          getFlightStatement.setInt(1,reservs.getInt("flight1"));
          flights = getFlightStatement.executeQuery();
          if(flights.next())
          {
            price1 = flights.getDouble("price");
            pass=true;
          }
          if(pass && reservs.getInt("flight2")>0)
          {
            flights.close();
            getFlightStatement.clearParameters();
            getFlightStatement.setInt(1,reservs.getInt("flight2"));
            flights = getFlightStatement.executeQuery();
            if(flights.next())
            {
              price2 = flights.getDouble("price");
            }
            else
            {
              pass = false;
            }
          }
          break;

        }
      }
      if(reservs!=null){reservs.close();}
      if(pass)
      {
        double totalCost = price1+price2;
        remaining = payReservation(totalCost,reservationId);
        if(remaining[0] == -1)
        {
          resMessage = "User has only "+remaining[1]+" in account but itinerary costs "+totalCost+"\n";
        }
        else
        {
          resMessage = ("Paid reservation: "+reservationId+" remaining balance: "+remaining[1]+"\n");
        }
      }
      commitTransaction();
    }
    catch(SQLException e)
    {
      e.printStackTrace();
    }
    finally {
      if (reservs != null) {
        try {
          reservs.close();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
      if (flights != null) {
        try {
          flights.close();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
    //return("Cannot find unpaid reservation " + reservationId + " under user: " + username + "\n");
    if(!pass)
    {
      resMessage = "Failed to pay for reservation " + reservationId + "\n";
    }
    return resMessage;
  }

  private double[] payReservation(double totalCost,int reservationId)
  {
    ResultSet money = null;
    double[] vals = {-1,0};
    double balance=0;
    double newBalance =0;
    double pass = -1;
    try
    {
      beginTransaction();
      getUserAcctStatement.clearParameters();
      getUserAcctStatement.setString(1,username);
      money = getUserAcctStatement.executeQuery();
      money.next();
      balance = money.getInt("balance");
      if(balance>=totalCost)
      {
        newBalance = balance-totalCost;
        updateUserAcctStatement.clearParameters();
        updateUserAcctStatement.setDouble(1,newBalance);
        updateUserAcctStatement.setString(2,username);
        updateUserAcctStatement.executeUpdate();
        updateReservationPaidStatement.clearParameters();
        updateReservationPaidStatement.setBoolean(1,true);
        updateReservationPaidStatement.setString(2,username);
        updateReservationPaidStatement.setInt(3,reservationId);
        updateReservationPaidStatement.executeUpdate();
        pass = 1;
      }
      else
      {
        newBalance = balance;
        pass=-1;
      }
      vals[0]=pass;
      vals[1]=newBalance;
      commitTransaction();
    }
    catch(SQLException e){e.printStackTrace();}
    finally {
      if (money != null) {
        try {
          money.close();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
    return vals;
  }

  private boolean refundReservation(double totalCost,int reservationId)
  {
    ResultSet money = null;
    double[] vals = {-1,0};
    double balance=0;
    double newBalance =0;
    boolean pass = false;
    try
    {
      getUserAcctStatement.clearParameters();
      getUserAcctStatement.setString(1,username);
      money = getUserAcctStatement.executeQuery();
      money.next();
      balance = money.getInt("balance");
      newBalance = balance+totalCost;
      updateUserAcctStatement.clearParameters();
      updateUserAcctStatement.setDouble(1,newBalance);
      updateUserAcctStatement.setString(2,username);
      updateUserAcctStatement.executeUpdate();
      pass=true;
    }
    catch(SQLException e){e.printStackTrace();}
    finally {
      if (money != null) {
        try {
          money.close();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
    return pass ;
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

  private void oneStopFlightQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries,int numSoFar,StringBuffer sb) throws SQLException
  {
    int itenSoFar = numSoFar;
    ResultSet oneStopResults = null;
    try{
      //beginTransaction();//unnecessary
      safeSearchQueryOneStopStatement.clearParameters();
      safeSearchQueryOneStopStatement.setInt(1,numberOfItineraries-itenSoFar);
      safeSearchQueryOneStopStatement.setString(2,originCity);
      safeSearchQueryOneStopStatement.setString(3,destinationCity);
      safeSearchQueryOneStopStatement.setInt(4,dayOfMonth);
      oneStopResults = safeSearchQueryOneStopStatement.executeQuery();
      //commitTransaction();//unnecessary
    }
    catch(SQLException e) {e.printStackTrace();}
    while (oneStopResults.next())
    {

      int result_year = oneStopResults.getInt("f1year");
      int result_monthId = oneStopResults.getInt("f1month");
      int result_dayOfMonth = oneStopResults.getInt("f1dom");
      String result_carrierId1 = oneStopResults.getString("f1cid");
      String result_originCity1 = oneStopResults.getString("f1oc");
      String result_destCity1 = oneStopResults.getString("f1dc");
      double price1 = oneStopResults.getDouble("f1price");
      int flightID1 = oneStopResults.getInt("f1id");
      int flightNum1 = oneStopResults.getInt("f1flightnum");
      double result_time1 = oneStopResults.getDouble("f1at");
      int capacity1 = oneStopResults.getInt("f1c");
      //now for the second item in the flight iten
      String result_carrierId2 = oneStopResults.getString("carrier_id");
      String result_originCity2 = oneStopResults.getString("origin_city");
      String result_destCity2 = oneStopResults.getString("dest_city");
      double price2 = oneStopResults.getDouble("price");
      int flightID2 = oneStopResults.getInt("fid");
      int flightNum2 = oneStopResults.getInt("flight_num");
      double result_time2 = oneStopResults.getDouble("actual_time");
      int capacity2 = oneStopResults.getInt("capacity");
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
    //return itenSoFar;
  }

  private int directFlightQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries,int numSoFar,StringBuffer sb) throws SQLException
  {
    int itenSoFar = numSoFar;
    ResultSet directResults = null;
    try{
      //beginTransaction();//unnecessary
      safeSearchQueryStatement.clearParameters();
      safeSearchQueryStatement.setInt(1,numberOfItineraries-itenSoFar);
      safeSearchQueryStatement.setString(2,originCity);
      safeSearchQueryStatement.setString(3,destinationCity);
      safeSearchQueryStatement.setInt(4,dayOfMonth);
      directResults = safeSearchQueryStatement.executeQuery();
      //commitTransaction();
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

    return itenSoFar;

  }
  //works!!!

  //TODO, is this zero indexed? if they ask for ten itineraries, we will bre returning numbers 0 through 9.
  private String safeFlightQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries) throws SQLException
  {
    StringBuffer sb = new StringBuffer();
    int itenSoFar = 0;
    ResultSet oneHopResults = null;
    try
    {
      // one hop itineraries
      itenSoFar = directFlightQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries,0,sb);
      if(directFlight == false && itenSoFar<=numberOfItineraries)
      {
        oneStopFlightQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries,itenSoFar,sb);
      }

      if(username != null)
      {
        insertUserQuery(originCity,destinationCity,directFlight,dayOfMonth,numberOfItineraries);
      }
    } catch (SQLException e) { e.printStackTrace(); }

    return sb.toString();
  }

  private void insertUserQuery(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                   int numberOfItineraries)
   {
     ResultSet insertQuery = null;
     try
     {
       beginTransaction();
       //first we check / drop the row with this username associated with it
       dropSearchStatement.clearParameters();
       dropSearchStatement.setString(1,username);

       dropSearchStatement.executeUpdate();
       insertSearchStatement.clearParameters();
       insertSearchStatement.setString(1,username);
       insertSearchStatement.setString(2,originCity);
       insertSearchStatement.setString(3,destinationCity);
       insertSearchStatement.setBoolean(4,directFlight);
       insertSearchStatement.setInt(5,dayOfMonth);
       insertSearchStatement.setInt(6,numberOfItineraries);
       insertSearchStatement.executeUpdate();
       //then we add our new search query and release.
       commitTransaction();
     } catch (SQLException e) { e.printStackTrace(); }
   }

}
