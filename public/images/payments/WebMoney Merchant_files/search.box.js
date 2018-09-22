function initializeSearch(inputId, emptyClass, buttonId, dropdownId, popupId, findCallback) {
    $(inputId).keypress(function(e){
        if (e.which == 13) {
	          e.preventDefault();
	          $(inputId).blur();
	          $(buttonId).click();
	          return false;
        }
    });
      
    $(inputId).val($(inputId).attr('title'));
    $(inputId).addClass(emptyClass);
    $(inputId).attr('popupId', popupId);
			
    $(inputId).focus(function() {
        if ($(this).val() == $(this).attr('title'))
        {
            $(this).removeClass(emptyClass);
            $(this).val('');
        }
    });
			
    $(inputId).blur(function() {
        $(this).val($.trim($(this).val()));
			
        if ($(this).val() == '')
        {
            $(this).addClass(emptyClass);
            $(this).val($(this).attr('title'));
        }
        
        DisplayOptions(popupId, false);
    });
			
    $(buttonId).click(function() {
        var value = $(inputId).val();
        var title = $(inputId).attr('title');
        var where = $(inputId).attr('where');

        if (value.length > 0)
        {
          if (value != title)
          {	          
            findCallback(value, where);
          }
          else
          {
            $(inputId).focus();
          }
        }        
    });
 
    $(popupId).mouseleave(function() {      
        DisplayOptions(popupId, false);                        
    });
    
    $(popupId).click(function() {      
        DisplayOptions(popupId, false);                        
        $(inputId).focus(); 
    });
    
     $(dropdownId).click(function() {      
        ToggleOptions(popupId);                        
    });
}
 
function initializeOption(linkId, popupId)
{
    $(linkId).click(function() {
    
        var inputId = '#' + $(linkId).attr('input');

        var watermark = $(linkId).attr('watermark');
        var where = $(linkId).attr('where');
    
        setCurrentOption(linkId,'.search-more li a')
    
        writeSearchOptionToCookie(linkId);

        $(inputId).val('');
        $(inputId).attr('title', watermark);
        $(inputId).attr('where', where);
        $(inputId).focus();        
    		
    		var popupId = $(inputId).attr('popupId');
    		
        DisplayOptions(popupId, false);
        
        return false;
    });
}
 
function setCurrentOption(currentOptionId, OptionsSelector)
{
    $(OptionsSelector).removeClass('search-current');
    $(currentOptionId).addClass('search-current');
}
 
function setDefaultOption(linkId, emptyClass)
{
    var inputId = '#' + $(linkId).attr('input');

    var watermark = $(linkId).attr('watermark');
    var where = $(linkId).attr('where');

    $(inputId).attr('where', where);
    $(inputId).attr('title', watermark);
    $(inputId).val($(inputId).attr('title'));
    $(inputId).addClass(emptyClass);				
}

function readSearchOptionFromCookie()
{    
    return $.cookie('searchOption'); 
}

function writeSearchOptionToCookie(linkId)
{
    $.cookie('searchOption', linkId); 
}

function setDefaultOptionFromCookie(emptyClass, defaultValue)
{
    var linkId = readSearchOptionFromCookie();
    
    if (null == linkId)
    {
        linkId = defaultValue;
    }
    setDefaultOption(linkId, emptyClass);
    setCurrentOption(linkId, '.search-more li a');
}
 
function DisplayOptions(popupId, value)
{    
    var visible = $(popupId).css("display") == "block";
    
    if (visible != value)
    {
        $(popupId).css("display", value ? "block" : "none");
    }     
}

function ToggleOptions(popupId)
{    
    var visible = $(popupId).css("display") == "block";
    
    $(popupId).css("display", visible ? "none" : "block");         
} 

function DisplayOptions(popupId, value)
{    
    var visible = $(popupId).css("display") == "block";
    
    if (visible != value)
    {
        $(popupId).css("display", value ? "block" : "none");
    }     
}