var Magazine = {

  
  db: openDatabase('economist', '1.0', 'The Economist', 2 * 1024),

  setupDb: fuction(){
    db.transaction(function (tx) {
      tx.executeSql('CREATE TABLE IF NOT EXISTS magazine (id INTEGER PRIMARY KEY, section TEXT, title TEXT, headline TEXT, content TEXT)', []);
    });
  },
}
