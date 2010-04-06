function findTextareasAndCreateEditor()
{
    var areas = document.getElementsByTagName("textarea");
    for(var i=0; i < areas.length; i++)
    {
        //alert(areas[i].id);
        createInstance(areas[i].id);
    }
}
function createInstance(textarea_id)
{
    var textarea = document.getElementById(textarea_id);
    /***** build the preview manager *****/
    var panes = {input:textarea, preview:null, output:null};
    //var previewManager = new Attacklab.wmd.previewManager(panes);
    /***** build the editor and tell it to refresh the preview after commands *****/
    var editor = new Attacklab.wmd(textarea);
}