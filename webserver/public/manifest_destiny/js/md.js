$(document).ready(function(){
  ManifestDestiny.setupEvents();
});

var ManifestDestiny = {



  backButton: $('.back_button'),
  
  setupEvents: function(){
    $('li.item').click(function(){
      ManifestDestiny.selectArticle($(this)); 
    });
    $('.back_button').click(function(){
      $('#toc').show();
      $('.article').hide();
      $('.back_button').hide();
    });
  },

  selectArticle: function(item){
    section_id = (item[0].id).substr(1);
    $('#' + section_id).show();
    $('#toc').hide();
    $('.back_button').show();
    scroll(0,0);
  }

};
