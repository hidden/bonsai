wmd_options = { autostart: false };
var instances = [];

function findTextareasAndCreateEditor()
{
    var areas = document.getElementsByTagName("textarea");
    for(var i=0; i < areas.length; i++)
    {
        //alert(areas[i].id);
        createInstance(areas[i]);
    }
}
function createInstance(textarea)
{
    /***** build the preview manager *****/
    var panes = {input:textarea, preview:null, output:null};
    //var previewManager = new Attacklab.wmd.previewManager(panes);
    /***** build the editor and tell it to refresh the preview after commands *****/
    var editor = new Attacklab.wmd.editor(textarea);
}