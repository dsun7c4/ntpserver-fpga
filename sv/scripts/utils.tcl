# this is a collection of useful project utilities

# implement touch - opens a file updating the time stamp,
# creating it if it does not exist
proc touch {f} {
   set FILEIN [open $f w]
   close $FILEIN
}


proc add_source_files {target files {type ""}} {
    # Create $target fileset (if not found)
    if {[string equal [get_filesets -quiet $target] ""]} {
	create_fileset -srcset $target
    }


    # Set '$target' fileset object
    set obj [get_filesets $target]
    add_files -norecurse -fileset $obj $files

    # Set '$target' fileset file properties for remote files
    foreach file $files {
	set file_obj [get_files -of_objects [get_filesets $target] [list "*$file"]]
	if {$type ne ""} {
	    set_property "file_type" $type $file_obj
	}
	set_property "library" "work" $file_obj
    }
}


proc set_source_property {target files property value} {
    foreach file $files {
	set file_obj [get_files -of_objects [get_filesets $target] [list "*$file"]]
	if { ![get_property "is_locked" $file_obj] } {
	    set_property $property $value $file_obj
	}
    }
}
