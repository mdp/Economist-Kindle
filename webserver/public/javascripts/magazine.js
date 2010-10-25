var Magazine = (function () {
  this.db = openDatabase('economist', '1.0', 'The Economist', 2 * 1024);
  this.latestPublishDate = null;
  this.currentLoadedEdition = null;
  this.articles = {};
  this.that = this;

  function setupDB(){
    db.transaction(function (tx) {
      tx.executeSql('CREATE TABLE IF NOT EXISTS magazine (id INTEGER PRIMARY KEY, edition_date TEXT, section TEXT, title TEXT, headline TEXT, rubric TEXT, content TEXT)', []);
    });
  }

  function resetDB(){
    db.transaction(function (tx) {
      tx.executeSql('DROP TABLE magazine', []);
    });
  }

  function loadArticles(){
    console.log('Loading articles from DB');
    db.transaction(function(tx) {
      tx.executeSql("SELECT * FROM magazine ORDER BY section ASC", [], function(tx, results) {
        if (results.rows && results.rows.length) {
          for (i = 0; i < results.rows.length; i++) {
            if (articles[results.rows.item(i).section] === undefined) {
              articles[results.rows.item(i).section] = []
            }
            articles[results.rows.item(i).section].push(results.rows.item(i));
          }
        }
      });
    });
  }

  function findLatestPublishDate(){
    if (this.latestPublishDate == null){
      $.ajax({
        url: '/current_edition.json',
        dataType: 'json',
        success: function(data){
          latestPublishDate = data.latest_publish_date;
        }
      })
    }
  }

  function loadLatestIssue(callback){
    var self = this;
    $.ajax({
      url: '/latest.json',
      dataType: 'json',
      success: function(data){
        var latestDate = new Date();
        db.transaction(function (tx) {
          $.each(data, function(i, item){
            console.log(item);
            tx.executeSql('INSERT INTO magazine (id, edition_date, section, title, headline, rubric, content) VALUES (?,?,?,?,?,?,?)', [
                          item['id'],
                          item['edition_date'],
                          item['section'],
                          item['title'],
                          item['headline'],
                          item['rubric'],
                          item['content']
            ], null, sqlFail);
          });
        }, txFail, callback);
      }
    });
    console.log("loading latest issue");
  }

  function txFail(err){
    console.log(err.message)
  }

  function sqlFail(err){console.log(err)}

  function init(callback){
    setupDB();
    findLatestPublishDate();
    loadLatestIssue(loadArticles);
  }

  return {init: init, loadLatestIssue: loadLatestIssue, resetDB: resetDB, articles: articles};
}());
Magazine.init()


