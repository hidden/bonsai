var current_parts = new Array();
     function lost_focus(){
                document.forms[0].elements["title"].focus();
             }

            function set_focus(part_name){
                document.forms[0].elements["parts["+part_name+"]"].focus();
            }

            //I18n.t("page_is_editing")
            function show_confirm(is_edited_by_another, part_id, part_name,text){
                if(is_edited_by_another && (!check_lock(part_id))){
                    lost_focus();
                    if(confirm(text)){
                        add_lock(part_id);
                        set_focus(part_name);
                    }else{
                        lost_focus();
                        return false;
                    }
                }else{
                add_lock(part_id);
                }
            }

            function add_lock(part_id){
                current_parts.push(part_id);
            }

            function check_lock(part_id){
                return (current_parts.indexOf(part_id) != -1);
            }

//I18n.t("manager_error")
{function testManagers(text){
                    var managers = document.getElementsByClassName("ManagerHidden");
                    if ((managers.length) >= 2) return true;
                    else{
                        alert(text);
                        return false;
                    }
                }

            }

