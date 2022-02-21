namespace TM
{
    void LoadMap()
    {
        if (PluginSettings::closeOverlayOnMapLoaded) UI::HideOverlay();
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        app.BackToMainMenu(); // If we're on a map, go back to the main menu else we'll get stuck on the current map
        while(!app.ManiaTitleControlScriptAPI.IsReady) {
            yield(); // Wait until the ManiaTitleControlScriptAPI is ready for loading the next map
        }
        app.ManiaTitleControlScriptAPI.PlayMap(loadMapURL, "", "");
    }

    bool IsMapLoaded(){
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if (app.RootMap is null) return false;
        else return true;
    }

    string CurrentTitlePack()
    {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if (app.LoadedManiaTitle is null) return "";
        string titleId = app.LoadedManiaTitle.TitleId;
#if MP4
        return titleId.SubStr(0, titleId.IndexOf("@"));
#else
        return titleId;
#endif
    }
}