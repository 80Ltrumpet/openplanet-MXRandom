class RMS : RMC
{
    int Skips = 0;
    int SurvivedTimeStart = -1;
    int SurvivedTime = -1;
    Resources::Texture@ SkipTex = Resources::GetTexture("src/Assets/Images/YEPSkip.png");

    int TimeLimit() override { return PluginSettings::RMC_SurvivalMaxTime * 60 * 1000; }

    void RenderTimer() override
    {
        UI::PushFont(TimerFont);
        if (RMC::IsRunning || RMC::EndTime > 0 || RMC::StartTime > 0) {
            if (RMC::IsPaused) UI::TextDisabled(RMC::FormatTimer(RMC::EndTime - RMC::StartTime));
            else UI::Text(RMC::FormatTimer(RMC::EndTime - RMC::StartTime));

            SurvivedTime = RMC::StartTime - SurvivedTimeStart;
            if (SurvivedTime > 0 && PluginSettings::RMC_SurvivalShowSurvivedTime) {
                UI::PopFont();
                UI::Dummy(vec2(0, 8));
                UI::PushFont(g_fontHeaderSub);
                UI::Text(RMC::FormatTimer(SurvivedTime));
            } else {
                UI::Dummy(vec2(0, 8));
            }
        } else {
            UI::TextDisabled(RMC::FormatTimer(TimeLimit()));
            UI::Dummy(vec2(0, 8));
        }
        UI::PopFont();
    }

    void RenderBelowGoalMedal() override
    {
        UI::Image(SkipTex, vec2(50,50));
        UI::SameLine();
        vec2 pos_orig = UI::GetCursorPos();
        UI::SetCursorPos(vec2(pos_orig.x, pos_orig.y+8));
        UI::PushFont(TimerFont);
        UI::Text(tostring(Skips));
        UI::PopFont();
        UI::SetCursorPos(pos_orig);
    }

    void SkipButton() override
    {
        if (UI::Button(Icons::PlayCircleO + " Skip")) {
            if (RMC::IsPaused) RMC::IsPaused = false;
            Skips += 1;
            Log::Trace("RMS: Skipping map");
            UI::ShowNotification("Please wait...");
            startnew(RMC::SwitchMap);
        }
        if (UI::Button(Icons::PlayCircleO + " Survival Free Skip")) {
            if (!UI::IsOverlayShown()) UI::ShowOverlay();
            RMC::IsPaused = true;
            Dialogs::Question("\\$f00"+Icons::ExclamationTriangle+" \\$zFree skips is only if the map is impossible or broken.\n\nAre you sure to skip?", function() {
                RMC::IsPaused = false;
                print("RMC: Survival Free Skip");
                UI::ShowNotification("Please wait...");
                startnew(RMC::SwitchMap);
            }, function(){RMC::IsPaused = false;});
        }
    }

    void NextMapButton() override
    {
        if(UI::Button(Icons::Play + " Next map")) {
            if (RMC::IsPaused) RMC::IsPaused = false;
            Log::Trace("RMS: Next map");
            UI::ShowNotification("Please wait...");
            RMC::EndTime += (3*60*1000);
            startnew(RMC::SwitchMap);
        }
    }

    void StartTimer() override
    {
        RMC::StartTime = Time::get_Now();
        RMC::EndTime = RMC::StartTime + TimeLimit();
        SurvivedTimeStart = Time::get_Now();
        RMC::IsPaused = false;
        RMC::IsRunning = true;
        startnew(RMC::TimerYield);
    }
}