#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ D�finition of the presentations ___________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit Video_PM_FC_ffmpeg Physical_model
#___________________________________________________________________________________________________________________________________________
proc Video_PM_FC_ffmpeg__Delayed_load_of_FF_MPEG {} {
   if {![info exists class(ffmpeg_init_OK)]} {
     if {[catch "load {[get_B207_files_root]FFMPEG_for_TCL.dll}" err]} {
       error "ERROR while trying to reload FFMPEG library:\n$err"
      } else {ffmpeg_init
	          FFMPEG_FSOUND_Init
	          global Video_PM_FC_ffmpeg
			  set Video_PM_FC_ffmpeg(ffmpeg_init_OK) 1
			  puts stderr "FFMPEG_for_TCL now post loaded :)"
	         }
    }
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg constructor {name descr args} {
 this inherited $name $descr
    
   this set_GDD_id CT_Video_FC_ffmpeg
   
   set this(is_updating) 0
   if {![info exists class(ffmpeg_init_OK)]} {
     if {[catch "load {[get_B207_files_root]FFMPEG_for_TCL.dll}" err]} {
       puts stderr "ERROR while loading FFMPEG library:\n$err"
	   after 1000 Video_PM_FC_ffmpeg__Delayed_load_of_FF_MPEG
      } else {ffmpeg_init
	          FFMPEG_FSOUND_Init
	          set class(ffmpeg_init_OK) 1
	         }
    }

   # Manage image buffers
   set this(index_current_video_buffer) 0
   set this(nb_video_buffers)           0
   set this(Pool_video_buffers)         [list]
   set this(video_buffer_size)          0
   
   set this(will_reupdate)              0
   
   set this(ffmpeg_id)                  ""
      
   # Synchronization
   set this(is_go_to_frame) 0
   
 # Terminate with configuration's parameters
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC Video_PM_FC_ffmpeg [P_L_methodes_set_Video] {} {}
Methodes_get_LC Video_PM_FC_ffmpeg [P_L_methodes_get_Video] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_accessors Video_PM_FC_ffmpeg [list ffmpeg_rap_img ffmpeg_start_ms ffmpeg_frame_num]

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters Video_PM_FC_ffmpeg [P_L_methodes_set_Video_FC_COMET_RE]

#___________________________________________________________________________________________________________________________________________
Inject_code Video_PM_FC_ffmpeg Play  {} {
 if {!$this(will_reupdate)} {
     FFMPEG_set_time_t0_now $this(ffmpeg_id)
	 this set_ffmpeg_start_ms [FFMPEG_get_time_t0_as_double $this(ffmpeg_id)]
	 # puts "Reset start ms to [this get_ffmpeg_start_ms] = $ms - 1000 * [this get_ffmpeg_frame_num] / double($this(ffmpeg_frame_rate)"
	 this Update_frame
	}
}

#___________________________________________________________________________________________________________________________________________
Inject_code Video_PM_FC_ffmpeg Pause {} {}
#___________________________________________________________________________________________________________________________________________
Inject_code Video_PM_FC_ffmpeg Stop  {} {
 set this(will_reupdate) 0
 FFMPEG_set_Video_pts_for_audio $this(ffmpeg_id) 0
 this go_to_frame 0 0
 this Update_frame 1
 set this(will_reupdate) 0
}

#___________________________________________________________________________________________________________________________________________
Inject_code Video_PM_FC_ffmpeg go_to_time {} {
 this go_to_frame [expr int($t * [this get_video_nbFrames])]
}

#___________________________________________________________________________________________________________________________________________
Inject_code Video_PM_FC_ffmpeg go_to_frame {} {
 if {[this get_video_source] != "WEBCAM" && $this(ffmpeg_id) != "" && [this get_video_source] != ""} {
   set this(is_go_to_frame) 1
   if {$this(is_updating)} {
	 after 3 [list $objName go_to_frame $nb $set_video_pts]
	 return
	}
   
   FFMPEG_Info_for_sound_Drain_all     $this(ffmpeg_id); FFMPEG_set_Video_pts_for_audio $this(ffmpeg_id) 0
   
   set this(ffmpeg_frame_num) $nb; [this get_Common_FC] set_num_frame $nb
   lassign [this get_readable_video_buffer] current_video_pts buf_r
   FFMPEG_Lock       $this(ffmpeg_id)
   FFMPEG_getImageNr $this(ffmpeg_id) $this(ffmpeg_frame_num) $buf_r
   FFMPEG_UnLock     $this(ffmpeg_id)
   this Fill_video_pool

   lassign [this get_readable_video_buffer] current_video_pts buf_r
   set current_video_dt [expr $current_video_pts * $this(video_time_base)]
   
 
   if {$set_video_pts} {
	    lassign [this get_readable_video_buffer] current_video_pts buf_r
	    FFMPEG_set_Video_pts_for_audio $this(ffmpeg_id) $current_video_pts
		FFMPEG_set_time_t0_from_video $this(ffmpeg_id)
		this set_ffmpeg_start_ms [FFMPEG_get_time_t0_as_double $this(ffmpeg_id)]
	   }
   FFMPEG_Synchronize_audio_with_video $this(ffmpeg_id)
   set this(is_go_to_frame) 0
  }
}
# Trace Video_PM_FC_ffmpeg go_to_frame

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg set_resolution {x y} {
 if {[this get_video_source] == "WEBCAM"} {
   if {[catch {$this(visu_cam) set_resolution $x $y} err]} {
     error "Error while setting the resolution in \"$objName set_resolution $x $y\""
    } else {if {$x != [$this(visu_cam) L] || $y != [$this(visu_cam) H]} {
				 [this get_Common_FC] set_resolution [$this(visu_cam) L] [$this(visu_cam) H]
				}
		   }
  }
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg set_video_source {s canal_audio}  {
 set this(is_updating) 1
 # Do we have to stop a ffmpeg stream?
 if {$this(ffmpeg_id) != ""} {
   puts "Closing video $this(ffmpeg_id)"
   set tmp_id $this(ffmpeg_id); set this(ffmpeg_id) ""
   this Stop
   this prim_Close_video
   FFMPEG_Info_for_sound_Drain_all $tmp_id
   FFMPEG_stopAcquisition          $tmp_id
   FFMPEG_Close_video_stream       $tmp_id
   puts "End of closing"
  }
  
 set num_cam 0
 if {$s == "WEBCAM" || [regexp {^WEBCAM([0-9])$} $s reco num_cam]} {
	 set is_webcam 1
	} else {set is_webcam 0}

 if {$is_webcam} {
   set this(ffmpeg_id) ""
   set visu_cam [Visu_Cam $num_cam]; set this(visu_cam) $visu_cam
	   set texture [$visu_cam Info_texture]
	   set tx [$texture Taille_reelle_x]; if {$tx == 0} {set tx 1}
	   set ty [$texture Taille_reelle_y]; if {$ty == 0} {set ty 1}
	   $objName prim_set_video_width  [$visu_cam get_resolution_x]
	   $objName prim_set_video_height [$visu_cam get_resolution_y]
	   $objName prim_set_B207_texture $texture
	   $objName prim_set_visu_cam     $visu_cam
  } else {
          if {$this(ffmpeg_id) != ""} {FFMPEG_Lock $this(ffmpeg_id); puts "Lock"; set unlock 1} else {set unlock 0}
          set this(ffmpeg_id) [FFMPEG_Open_video_stream $s]
		  set error_message [FFMPEG_get_error_message $this(ffmpeg_id)]
		  if {$error_message != ""} {
		     set tmp_id $this(ffmpeg_id); set this(ffmpeg_id) ""
			 puts "Error with stream $tmp_id"
			 FFMPEG_Info_for_sound_Drain_all $tmp_id
			 FFMPEG_stopAcquisition          $tmp_id
			 FFMPEG_Close_video_stream		 $tmp_id
			 
			 error $error_message
			}
          
		  
		  
          FFMPEG_set_Synchronisation_threshold $this(ffmpeg_id) 0
          set t  [FFMPEG_startAcquisition $this(ffmpeg_id)]
          set tx [FFMPEG_Width  $this(ffmpeg_id)]
          set ty [FFMPEG_Height $this(ffmpeg_id)]
		  this prim_set_video_width  $tx
		  this prim_set_video_height $ty
		  
          set this(ffmpeg_start_ms)   [clock milliseconds]; 
		  set this(ffmpeg_frame_num)  0
		  set this(ffmpeg_numFrames)  [FFMPEG_numFrames    $this(ffmpeg_id)]
          set this(ffmpeg_frame_rate) [FFMPEG_getFramerate $this(ffmpeg_id)]
		  
		  puts "Info video:\n\tffmpeg_numFrames : $this(ffmpeg_numFrames)\n\tffmpeg_frame_rate : $this(ffmpeg_frame_rate)"

		 # Video information
		  set this(video_time_base) [FFMPEG_get_Video_time_base $this(ffmpeg_id)]
		  puts "video_time_base = $this(video_time_base)"
		  this prim_set_video_time_base $this(video_time_base)
		  puts "video_time_base = $this(video_time_base) ... [this get_video_time_base]"
		  
         # Sound
          set sample_rate [FFMPEG_Sound_sample_rate $this(ffmpeg_id)]
          set cb_audio    [Get_FFMPEG_FMOD_Stream_Info_audio]
          set buf_len [expr int(2 * [FFMPEG_Nb_channels $this(ffmpeg_id)] * $sample_rate / [FFMPEG_getFramerate $this(ffmpeg_id)])]
          this prim_set_L_infos_sound [FFMPEG_Info_for_sound_CB $this(ffmpeg_id)]
		  
          FFMPEG_set_Debug_mode    $this(ffmpeg_id) 0
          FFMPEG_Audio_buffer_size $this(ffmpeg_id)
		  
		  this prim_set_sample_rate     $sample_rate
		  this prim_set_nb_channels     [FFMPEG_Nb_channels $this(ffmpeg_id)]
		  this prim_set_video_framerate $this(ffmpeg_frame_rate)
		  this prim_set_cb_audio        $cb_audio
		  this prim_set_video_nbFrames  [FFMPEG_get_nb_total_video_frames $this(ffmpeg_id)]
		  
		  set this(video_buffer_size)   $t
		  this Init_Pool_video_buffer   30
		  
		  this go_to_frame 0
		 

		  if {$unlock} {puts "UnLock"; FFMPEG_UnLock $this(ffmpeg_id)}
          puts "Info audio (Video_PM_P_BIGre $objName):\n\tbuf_len : $buf_len\n\tframerate : [FFMPEG_getFramerate $this(ffmpeg_id)]\n\tSample rate : $sample_rate\n\tnb channels : [FFMPEG_Nb_channels $this(ffmpeg_id)]\n\tcb_audio : $cb_audio\n\tnb frames : [FFMPEG_get_nb_total_video_frames $this(ffmpeg_id)]\n\tbuffer size : [FFMPEG_Audio_buffer_size $this(ffmpeg_id)]"
		  this Update_frame 1
		  
         }
		 
 # puts "  End of $objName Video_PM_FC_ffmpeg::set_video_source"
 set this(is_updating) 0
}
# Trace Video_PM_FC_ffmpeg set_video_source

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg Update_frame {{force_update 0}} {
 if {!$this(is_go_to_frame)} {
	 if {$this(is_updating)}     {return}
	 if {$this(ffmpeg_id) == ""} {return}
	 
	 set this(is_updating) 1

	 # Faire une v�rification avec l'information ptd de la video plutot...
	 # set ms [clock milliseconds]; 
	 # set dt [expr $ms - [this get_ffmpeg_start_ms]]
	 set dt [FFMPEG_get_delta_from_t0 $this(ffmpeg_id)]
	 lassign [this get_readable_video_buffer] current_video_pts buf_r
	 set current_video_dt [expr $current_video_pts * $this(video_time_base)]
	 if {($dt + 0.005) >= $current_video_dt} {set force_update 1; set num [expr 1+[this get_ffmpeg_frame_num]]} else {set num [this get_ffmpeg_frame_num]}

	 if {$force_update } {
	   # get images and put them from readable buffer
	   lassign [this get_readable_video_buffer] current_video_pts buf_r
	   this set_ffmpeg_frame_num        $num; [this get_Common_FC] set_num_frame $num
	   this set_last_buffer             $buf_r
	   this prim_Update_image           $buf_r
	 
	   lassign [this get_writable_video_buffer] video_pts buf_w
	   FFMPEG_Lock     $this(ffmpeg_id)
	   FFMPEG_getImage $this(ffmpeg_id) $buf_w
	   FFMPEG_UnLock   $this(ffmpeg_id)
	   set video_pts [FFMPEG_get_Video_pts $this(ffmpeg_id)]
	   this set_video_buffer_indexed [this get_index_writable_video_buffer] [list $video_pts $buf_w]
	   
	   FFMPEG_set_Video_pts_for_audio $this(ffmpeg_id) $current_video_pts

	   this Next_video_buffer
	  }
	}
	
 set this(is_updating) 0
 if {[this get_mode] == "PLAY"} {
   after 10 [list $objName Update_frame]
   set this(will_reupdate) 1
  } else {set this(will_reupdate) 0}
}
# Trace Video_PM_FC_ffmpeg Update_frame

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg Init_Pool_video_buffer {nb} {
 foreach video_pts__buf $this(Pool_video_buffers) {
   lassign $video_pts__buf video_pts buf
   FFMPEG_Release_buffer $buf
  }
  
 set this(Pool_video_buffers) [list]
 
 for {set i 0} {$i < $nb} {incr i} {
   set buf [FFMPEG_Get_a_buffer $this(video_buffer_size)]
   # puts "\tbuffer : $buf"
   lappend this(Pool_video_buffers) [list 0 $buf]
  }
  
 set this(nb_video_buffers)           $nb
 set this(index_current_video_buffer) 0
 
 this set_last_buffer [lindex [lindex $this(Pool_video_buffers) 0] 1]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg Fill_video_pool {} {
 for {set i 0} {$i < ($this(nb_video_buffers) / 2)} {incr i} {
   set index [expr ($this(index_current_video_buffer) + $i) % $this(nb_video_buffers)]
   lassign [this get_video_buffer_indexed $index] video_pts buf
   
   FFMPEG_getImage $this(ffmpeg_id) $buf
   set video_pts [FFMPEG_get_Video_pts $this(ffmpeg_id)]
   
   this set_video_buffer_indexed $index [list $video_pts $buf]
  }
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg get_video_buffer_indexed {i} {
 return [lindex $this(Pool_video_buffers) $i]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg set_video_buffer_indexed {i pts_buf} {
 set this(Pool_video_buffers) [lreplace $this(Pool_video_buffers) $i $i $pts_buf]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg get_readable_video_buffer {} {
 return [lindex $this(Pool_video_buffers) $this(index_current_video_buffer)]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg get_index_writable_video_buffer {} {
 return [expr ($this(index_current_video_buffer) + ($this(nb_video_buffers) / 2)) % $this(nb_video_buffers)]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg get_writable_video_buffer {} {
 return [lindex $this(Pool_video_buffers) [this get_index_writable_video_buffer]]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg Next_video_buffer {} {
 set this(index_current_video_buffer) [expr (1 + $this(index_current_video_buffer)) % $this(nb_video_buffers)]
 return $this(index_current_video_buffer)
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg get_video_pts {} {
 return [FFMPEG_get_Video_pts $this(ffmpeg_id)]
}

#___________________________________________________________________________________________________________________________________________
method Video_PM_FC_ffmpeg get_audio_pts {} {
 return [FFMPEG_get_Video_pts_for_audio $this(ffmpeg_id)]
}