/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function checkExpand(ch) {
    var obj=document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if(obj && obj.style) obj.style.display=
    "none" == obj.style.display ?"" : "none"
}

// Change Location of pulldown.
document.observe("dom:loaded", function() {
    new Insertion.After($('issue_tracker_id'), $('template_area'));
    //ConnectedSelect(['issue_tracker_id','issue_template']);    
});


function load_template(evt, target_url, token) {
 if (evt.target.value != "") { 
    new Ajax.Request(target_url,
      {asynchronous:true, evalScripts:true, 
         onComplete:function(request){
           eval("var template = " + request.responseText);
           $('issue_description').value = template.description
           $('issue_subject').value = template.title
         },
       parameters:'issue_template=' + encodeURIComponent(evt.target.value)
         + '&authenticity_token=' + encodeURIComponent(token)
      }
     ); 
    }  
}

function set_pulldown(evt, target_url, token) {
      new Ajax.Request(target_url,
      {  asynchronous:true, evalScripts:true, 
         onComplete:function(request){
           Element.update('issue_template', request.responseText);
         },        
       parameters:'issue_tracker_id=' + encodeURIComponent(evt.target.value)
         + '&authenticity_token=' + encodeURIComponent(token) 
      }
     ); 
}
