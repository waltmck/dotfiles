// import matugen from "./matugen"
// import hyprland from "./hyprland"
import tmux from "./tmux"
import gtk from "./gtk"
import lowBattery from "./battery"
import notifications from "./notifications"

export default function init() {
    try {
        gtk()
        tmux()
        // matugen() don't init matugen TODO deleta file
        lowBattery()
        notifications()
        // hyprland() Don't init hyprland TODO delete file
    } catch (error) {
        logError(error)
    }
}
