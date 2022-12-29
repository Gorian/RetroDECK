#!/bin/bash

# VARIABLES SECTION

#rd_conf="retrodeck.cfg" # uncomment for standalone testing
#source functions.sh # uncomment for standalone testing

source /app/libexec/global.sh # uncomment for flatpak testing
source /app/libexec/functions.sh # uncomment for flatpak testing

# DIALOG SECTION

# Configurator Option Tree

# Welcome
#     - Move RetroDECK data directory
#       - Migrate everything
#     - Change Emulator Options
#         - RetroArch
#           - Change Rewind Setting
#     - RetroAchivement login
#       - Login prompt
#     - Reset RetroDECK
#       - Reset RetroArch
#       - Reset Specific Standalone Emulator
#           - Reset Yuzu
#           - Reset Dolphin
#           - Reset PCSX2
#           - Reset MelonDS
#           - Reset Citra
#           - Reset RPCS3
#           - Reset Ryujinx
#           - Reset XEMU
#           - Reset PPSSPP
#           - Reset Duckstation
#       - Reset All Standalone Emulators
#       - Reset Tools
#       - Reset All

# Code for the menus should be put in reverse order, so functions for sub-menus exists before it is called by the parent menu

# DIALOG TREE FUNCTIONS

configurator_reset_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Reset Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --column="Choice" --column="Action" \
  "Reset RetroArch" "Reset RetroArch to default settings" \
  "Reset Specific Standalone" "Reset only one specific standalone emulator to default settings" \
  "Reset All Standalones" "Reset all standalone emulators to default settings" \
  "Reset Tools" "Reset Tools menu entries" \
  "Reset All" "Reset RetroDECK to default settings" )

  case $choice in

  "Reset RetroArch" )
    ra_init
    configurator_process_complete_dialog "resetting RetroArch"
    ;;

  "Reset Specific Standalone" )
    emulator_to_reset=$(zenity --list \
    --title "RetroDECK Configurator Utility - Reset Specific Standalone Emulator" --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --text="Which emulator do you want to reset to default?" \
    --hide-header \
    --column=emulator \
    "RetroArch" \
    "Citra" \
    "Dolphin" \
    "Duckstation" \
    "MelonDS" \
    "PCSX2" \
    "PPSSPP" \
    "RPCS3" \
    "Ryujinx" \
    "XEMU" \
    "Yuzu")

    case $emulator_to_reset in

    "RetroArch" )
      ra_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "Citra" )
      citra_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "Dolphin" )
      dolphin_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "Duckstation" )
      duckstation_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "MelonDS" )
      melonds_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "PCSX2" )
      pcsx2_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "PPSSPP" )
      ppssppsdl_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "RPCS3" )
      rpcs3_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "Ryujinx" )
      ryujinx_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "XEMU" )
      xemu_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "Yuzu" )
      yuzu_init
      configurator_process_complete_dialog "resetting $emulator_to_reset"
    ;;

    "" ) # No selection made or Back button clicked
      configurator_reset_dialog
    ;;

    esac
  ;;

"Reset All Standalones" )
  standalones_init
  configurator_process_complete_dialog "resetting standalone emulators"
;;

"Reset Tools" )
  tools_init
  configurator_process_complete_dialog "resetting the tools menu"
;;

"Reset All" )
  zenity --icon-name=net.retrodeck.retrodeck --info --no-wrap \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --title "RetroDECK Configurator Utility - Reset RetroDECK" \
  --text="You are resetting RetroDECK to its default state.\n\nAfter the process is complete you will need to exit RetroDECK and run it again."
  rm -f "$lockfile"
  configurator_process_complete_dialog "resetting RetroDECK"
;;

"" ) # No selection made or Back button clicked
  configurator_welcome_dialog
;;

  esac
}

configurator_retroachivement_dialog() {
  login=$(zenity --forms --title="RetroDECK Configurator Utility - RetroArch RetroAchievements Login" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --text="Enter your RetroAchievements Account details.\n\nBe aware that this tool cannot verify your login details and currently only supports logging in with RetroArch.\nFor registration and more info visit\nhttps://retroachievements.org/\n" \
  --separator="=SEP=" \
  --add-entry="Username" \
  --add-password="Password")

  if [ $? == 0 ]; then # OK button clicked
    arrIN=(${login//=SEP=/ })
    user=${arrIN[0]}
    pass=${arrIN[1]}

    set_setting_value $raconf cheevos_enable true retroarch
    set_setting_value $raconf cheevos_username $user retroarch
    set_setting_value $raconf cheevos_password $pass retroarch

    configurator_process_complete_dialog "logging in to RetroArch RetroAchievements"
  else
    configurator_welcome_dialog
  fi

}

configurator_update_dialog() {
  configurator_generic_dialog "This feature is not available yet"
  configurator_welcome_dialog
}

configurator_power_user_changes_dialog() {
  zenity --title "RetroDECK Configurator Utility - Power User Options" --question --no-wrap --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --text="Making manual changes to an emulators configuration may create serious issues,\nand some settings may be overwitten during RetroDECK updates.\n\nSome standalone emulator functions may not work properly outside of Desktop mode.\n\nPlease continue only if you know what you're doing.\n\nDo you want to continue?"

  if [ $? == 0 ]; then # OK button clicked
    emulator=$(zenity --list \
    --title "RetroDECK Configurator Utility - Power User Options" --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --text="Which emulator do you want to configure?" \
    --hide-header \
    --column=emulator \
    "RetroArch" \
    "Citra" \
    "Dolphin" \
    "Duckstation" \
    "MelonDS" \
    "PCSX2-QT" \
    "PCSX2-Legacy" \
    "PPSSPP" \
    "RPCS3" \
    "Ryujinx" \
    "XEMU" \
    "Yuzu")

    case $emulator in

    "RetroArch" )
      retroarch
    ;;

    "Citra" )
      citra-qt
    ;;

    "Dolphin" )
      dolphin-emu
    ;;

    "Duckstation" )
      duckstation-qt
    ;;

    "MelonDS" )
      melonDS
    ;;

    "PCSX2-QT" )
      pcsx2-qt
    ;;

    "PCSX2-Legacy" )
      pcsx2
    ;;

    "PPSSPP" )
      PPSSPPSDL
    ;;

    "RPCS3" )
      rpcs3
    ;;

    "Ryujinx" )
      ryujinx-wrapper
    ;;

    "XEMU" )
      xemu
    ;;

    "Yuzu" )
      yuzu
    ;;

    "" ) # No selection made or Back button clicked
      configurator_options_dialog
    ;;

    esac
  else
    configurator_options_dialog
  fi
}

configurator_retroarch_rewind_dialog() {
  if [[ $(get_setting_value $raconf rewind_enable retroarch) == "true" ]]; then
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - Rewind" \
    --text="Rewind is currently enabled. Do you want to disable it?."

    if [ $? == 0 ]
    then
      set_setting_value $raconf "rewind_enable" "false" retroarch
      configurator_process_complete_dialog "disabling Rewind"
    else
      configurator_options_dialog
    fi
  else
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator - Rewind" \
    --text="Rewind is currently disabled, do you want to enable it?\n\nNOTE:\nThis may impact performance expecially on the latest systems."

    if [ $? == 0 ]
    then
      set_setting_value $raconf "rewind_enable" "true" retroarch
      configurator_process_complete_dialog "enabling Rewind"
    else
      configurator_options_dialog
    fi
  fi
}

configurator_retroarch_options_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - RetroArch Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --column="Choice" --column="Action" \
  "Change Rewind Setting" "Enable or disable the Rewind function in RetroArch" )

  case $choice in

  "Change Rewind Setting" )
    configurator_retroarch_rewind_dialog
  ;;

  "" ) # No selection made or Back button clicked
    configurator_options_dialog
  ;;

  esac
}

configurator_options_dialog() {
  choice=$(zenity --list --title="RetroDECK Configurator Utility - Change Options" --cancel-label="Back" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --column="Choice" --column="Action" \
  "Change RetroArch Settings" "Change settings specific to RetroArch" \
  "Power User Changes" "Make changes directly in an emulator" )

  case $choice in

  "Change RetroArch Settings" )
    configurator_retroarch_options_dialog
  ;;

  "Power User Changes" )
    configurator_power_user_changes_dialog
  ;;

  "" ) # No selection made or Back button clicked
    configurator_welcome_dialog
  ;;

  esac
}

configurator_move_dialog() {
  if [[ -d $rdhome ]]; then
    destination=$(configurator_destination_choice_dialog "RetroDECK Data" "Please choose a destination for the RetroDECK data folder.")
    case $destination in

    "Back" )
      configurator_move_dialog
    ;;

    "Internal Storage" )
      if [[ ! -L "$HOME/retrodeck" && -d "$HOME/retrodeck" ]]; then
        configurator_generic_dialog "The RetroDECK data folder is already at that location, please pick a new one."
        configurator_move_dialog
      else
        configurator_generic_dialog "Moving RetroDECK data folder to $destination"
        unlink $HOME/retrodeck # Remove symlink for $rdhome
        move $rdhome "$HOME"
        if [[ ! -d $rdhome && -d $HOME/retrodeck ]]; then # If the move succeeded
          rdhome="$HOME/retrodeck"
          roms_folder="$rdhome/roms"
          saves_folder="$rdhome/saves"
          states_folder="$rdhome/states"
          bios_folder="$rdhome/bios"
          media_folder="$rdhome/downloaded_media"
          themes_folder="$rdhome/themes"
          emulators_post_move
          conf_write

          configurator_process_complete_dialog "moving the RetroDECK data directory to internal storage"
        else
          configurator_generic_dialog "The moving process was not completed, please try again."
        fi
      fi
    ;;

    "SD Card" )
      if [[ -L "$HOME/retrodeck" && -d "$sdcard/retrodeck" && "$rdhome" == "$sdcard/retrodeck" ]]; then
        configurator_generic_dialog "The RetroDECK data folder is already configured to that location, please pick a new one."
        configurator_move_dialog
      else
        if [[ ! -w $sdcard ]]; then
          configurator_generic_dialog "The SD card was found but is not writable\nThis can happen with cards formatted on PC or for other reasons.\nPlease format the SD card through the Steam Deck's Game Mode and try the moving process again."
          configurator_welcome_dialog
        else
          if [[ $(verify_space $rdhome $sdcard) == "true" ]];then
            configurator_generic_dialog "Moving RetroDECK data folder to $destination"
            if [[ -L "$HOME/retrodeck/roms" ]]; then # Check for ROMs symlink user may have created
                unlink "$HOME/retrodeck/roms"
            fi

            (
            dir_prep "$sdcard/retrodeck" "$rdhome"
            ) |
            zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --pulsate --auto-close \
            --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
            --title "RetroDECK Configurator Utility - Move in Progress" \
            --text="Moving directory $rdhome to new location of $sdcard/retrodeck, please wait."

            if [[ -L $rdhome && ! $rdhome == "$HOME/retrodeck" ]]; then # Clean up extraneus symlinks from previous moves
              unlink $rdhome
            fi

            if [[ ! -L "$HOME/retrodeck" ]]; then # Always link back to original directory
              ln -svf "$sdcard/retrodeck" "$HOME/retrodeck"
            fi

            rdhome="$sdcard/retrodeck"
            roms_folder="$rdhome/roms"
            saves_folder="$rdhome/saves"
            states_folder="$rdhome/states"
            bios_folder="$rdhome/bios"
            media_folder="$rdhome/downloaded_media"
            themes_folder="$rdhome/themes"
            emulators_post_move
            conf_write
            configurator_process_complete_dialog "moving the RetroDECK data directory to SD card"
          else
            zenity --icon-name=net.retrodeck.retrodeck --error --no-wrap \
            --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
            --title "RetroDECK Configurator Utility - Move Directories" \
            --text="The destination directory you have selected does not have enough free space for the files you are trying to move.\n\nPlease select a new destination or free up some space."
          fi
        fi
      fi
    ;;

    "Custom Location" )
      configurator_generic_dialog "Select the root folder you would like to store the RetroDECK data folder in.\n\nA new folder \"retrodeck\" will be created in the destination chosen."
      custom_dest=$(browse "RetroDECK directory location")
      if [[ ! -w $custom_dest ]]; then
          configurator_generic_dialog "The destination was found but is not writable\nThis can happen if RetroDECK does not have permission to write to this location. This can typically be solved through the utility Flatseal, please make the needed changes and try the moving process again."
          configurator_welcome_dialog
      else
        if [[ $(verify_space $rdhome $custom_dest) ]];then
          configurator_generic_dialog "Moving RetroDECK data folder to $custom_dest/retrodeck"
          if [[ -L $rdhome/roms ]]; then # Check for ROMs symlink user may have created
            unlink $rdhome/roms
          fi

          (
          dir_prep "$custom_dest/retrodeck" "$rdhome"
          ) |
          zenity --icon-name=net.retrodeck.retrodeck --progress --no-cancel --pulsate --auto-close \
          --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
          --title "RetroDECK Configurator Utility - Move in Progress" \
          --text="Moving directory $rdhome to new location of $custom_dest/retrodeck, please wait."

          if [[ -L $rdhome && ! $rdhome == "$HOME/retrodeck" ]]; then # Clean up extraneus symlinks from previous moves
            unlink $rdhome
          fi

          if [[ ! -L "$HOME/retrodeck" ]]; then
            ln -svf "$custom_dest/retrodeck" "$HOME/retrodeck"
          fi

          rdhome="$custom_dest/retrodeck"
          roms_folder="$rdhome/roms"
          saves_folder="$rdhome/saves"
          states_folder="$rdhome/states"
          bios_folder="$rdhome/bios"
          media_folder="$rdhome/downloaded_media"
          themes_folder="$rdhome/themes"
          emulators_post_move
          conf_write
          configurator_process_complete_dialog "moving the RetroDECK data directory to SD card"
        else
          zenity --icon-name=net.retrodeck.retrodeck --error --no-wrap \
          --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
          --title "RetroDECK Configurator Utility - Move Directories" \
          --text="The destination directory you have selected does not have enough free space for the files you are trying to move.\n\nPlease select a new destination or free up some space."
        fi
      fi
    ;;

    esac
  else
    configurator_generic_dialog "The RetroDECK data folder was not found at the expected location.\n\nThis may have happened if the folder was moved manually.\n\nPlease select the current location of the RetroDECK data folder."
    rdhome=$(browse "RetroDECK directory location")
    roms_folder="$rdhome/roms"
    saves_folder="$rdhome/saves"
    states_folder="$rdhome/states"
    bios_folder="$rdhome/bios"
    media_folder="$rdhome/downloaded_media"
    themes_folder="$rdhome/themes"
    emulator_post_move
    conf_write
    configurator_generic_dialog "RetroDECK data folder now configured at $rdhome. Please start the moving process again."
    configurator_move_dialog
  fi
}

configurator_welcome_dialog() {
  # Clear the variables
  source=
  destination=
  action=
  setting=
  setting_value=

  choice=$(zenity --list --title="RetroDECK Configurator Utility" --cancel-label="Quit" \
  --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
  --column="Choice" --column="Action" \
  "Move Files" "Move files between internal/SD card or to custom locations" \
  "Change Options" "Adjust how RetroDECK behaves" \
  "RetroAchivements" "Log in to RetroAchievements" \
  "Reset" "Reset parts of RetroDECK" )

  case $choice in

  "Move Files" )
    configurator_generic_dialog "This option will move the RetroDECK data folder (ROMs, saves, BIOS etc.) to a new location.\n\nPlease choose where to move the RetroDECK data folder."
    configurator_move_dialog
  ;;

  "Change Options" )
    configurator_options_dialog
  ;;

  "RetroAchivements" )
    configurator_retroachivement_dialog
  ;;

  "Reset" )
    configurator_reset_dialog
  ;;

  "Quit" )
    exit 0
  ;;

  esac
}

# START THE CONFIGURATOR

configurator_welcome_dialog