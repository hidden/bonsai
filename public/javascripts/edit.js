var current_parts = new Array();
            function lost_focus(){
                var edit_form = document.forms["edit_form"];
                if(edit_form != null)
                    edit_form.title.focus();
             }

            function set_focus(part_name){
                var edit_form = document.forms["edit_form"];
                if(edit_form != null)
                    edit_form.elements["parts["+part_name+"]"].focus();
            }


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


{function testManagers(text){
                    var managers = document.getElementsByClassName("ManagerHidden");
                    if ((managers.length) >= 2) return true;
                    else{
                        alert(text);
                        return false;
                    }
                }

            }

