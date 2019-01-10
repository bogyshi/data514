import dataset
db = dataset.connect('sqlite:///testdb.data')
results = db.query("""


""")

newTable = db['new_table']
newTable.insert(dict(name = 'John Doe',age=37))
#note altar table may be something to look at
