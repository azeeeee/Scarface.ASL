// Scarface: The World is Yours - LiveSplit autosplitter
// Target: v1.0.0.2
//
// Splits on the mission-complete stats screen, and only when the mission was
// actually COMPLETED.
//
// Stats screen (mission ended, game paused):
//   missionGroup == 0        the mission group slot at [node + 0xC] is cleared
//   paused       == 1        gPauseGame
//   missionName  == ...      internal name of the mission that just ended
//
// Completion flag:
//   missionFailFlag1 (0x00819640) is 0 on the mission-complete stats screen and
//   1 when the mission was failed. It is set at the moment of failure (measured
//   9 s before the fail screen appears) and cleared when the mission restarts,
//   so it is already correct on the first tick of the stats screen.
//   missionSucceeded (0x00827588) and the other flags are logged but NOT used:
//   they flicker during missions and are not consistent across missions.
//
// The test is level triggered, not edge triggered: the stats screen keeps these
// values until the next mission loads, so one dropped tick cannot lose a split.
// Each mission has its own "done" flag, so it cannot double split.
//
// Mission ids below are the game's internal names. The name at the stats screen
// is the LAST internal part of a mission, which is why The Fall is S01c (S01a
// has no stats screen) and Buyback the Mansion is S03 (S02 is its first part).
//
// Timer starts when the first mission of the run (The Fall part 1, S01a) loads.
//
// Settings are grouped per district. A district checkbox enables/disables all of
// its missions at once (children inherit the parent value).
//
// Clean build: no logging and no file writes. Everything outside the state
// block is plain game-memory reading, so this file works on its own.

state("scarface", "v1.0.0.2")
{
    // gPauseGame: 1 while the game is paused (stats screen, save prompt, menus).
    byte paused : "scarface.exe", 0x40AC04, 0x177;

    int missionGroup    : "scarface.exe", 0x40A714, 0x14, 0xC, 0x0;
    int missionStage    : "scarface.exe", 0x40A714, 0x14, 0x14, 0x0;
    int missionStageNum : "scarface.exe", 0x40A714, 0x14, 0x1C, 0x0;

    // Static .data global pointing at the live mission string table.
    string11 missionName : "scarface.exe", 0x41C6A4, 0x0;

    // Mission result flags (see header).
    int missionSucceeded : "scarface.exe", 0x427588;
    int missionFailFlag1 : "scarface.exe", 0x419640;
    int missionFailFlag2 : "scarface.exe", 0x422B68;
    int missionFailFlag3 : "scarface.exe", 0x427BCC;
}

startup
{
    settings.Add("CatLittleHavana", true, "Little Havana");
    settings.Add("CatDowntown", true, "Downtown");
    settings.Add("CatSouthBeach", true, "South Beach");
    settings.Add("CatNorthBeach", true, "North Beach");
    settings.Add("CatEndgame", true, "Endgame");
    settings.Add("CatOptional", false, "Optional / Junk (untested)");

    settings.Add("S01c", true, "Mansion Shootout", "CatLittleHavana");
    settings.Add("S03", true, "Buyback the Mansion", "CatLittleHavana");
    settings.Add("S04", true, "Gaspar Gomez", "CatLittleHavana");
    settings.Add("S05", true, "Jerry The Banker", "CatLittleHavana");
    settings.Add("M_A1B", true, "Pedro's Pawn Shop", "CatLittleHavana");
    settings.Add("M_A2B", true, "Cabana Cigar", "CatLittleHavana");
    settings.Add("M_A3B", true, "Oakley's Drive In", "CatLittleHavana");
    // Babylon Club Redux: The mission doesn't have the stats screen, so it won't split.
    // settings.Add("S13", true, "Babylon Club Redux", "CatLittleHavana");
    settings.Add("S14", true, "The Diaz Brothers", "CatLittleHavana");
    settings.Add("M_SHA", true, "Havana Storehouse", "CatLittleHavana");
    settings.Add("S07a", true, "Freedom Town Redux", "CatDowntown");
    settings.Add("M_B1B", true, "Liquor Store", "CatDowntown");
    settings.Add("M_B2B", true, "Fidel's", "CatDowntown");
    settings.Add("M_B3B", true, "Shotgun Bar", "CatDowntown");
    settings.Add("M_B4B", true, "Babylon Club", "CatDowntown");
    settings.Add("M_SHB", true, "Marina Storage", "CatDowntown");
    settings.Add("M_D1B", true, "Macau Fast Food", "CatSouthBeach");
    settings.Add("M_D2B", true, "Chi Peso Trattoria", "CatSouthBeach");
    settings.Add("M_D3B", true, "Swansong Hotel", "CatSouthBeach");
    settings.Add("M_D4B", true, "Sun Ray Hotel", "CatSouthBeach");
    settings.Add("S09", true, "Kill Nacho Contreras", "CatSouthBeach");
    settings.Add("A51", true, "The Dock Boss", "CatSouthBeach");
    settings.Add("A51b", true, "The Informer", "CatSouthBeach");
    settings.Add("S10", true, "Nacho's Tanker", "CatSouthBeach");
    settings.Add("M_SHD", true, "Shoreline Storage", "CatSouthBeach");
    settings.Add("S11", true, "Un-Load", "CatSouthBeach");
    settings.Add("S12", true, "Deliver", "CatSouthBeach");
    settings.Add("M_C1B", true, "Angel Dust Donuts", "CatNorthBeach");
    settings.Add("M_C2B", true, "Whippet Gambling", "CatNorthBeach");
    settings.Add("M_C3B", true, "Peninsula Lounge", "CatNorthBeach");
    settings.Add("M_C4B", true, "Stein Jewelry", "CatNorthBeach");
    settings.Add("M_C5B", true, "Coco's Lounge and Disco", "CatNorthBeach");
    settings.Add("M_SHC", true, "Leopard Rail Storage", "CatNorthBeach");
    settings.Add("A22", true, "The Plantation", "CatEndgame");
    settings.Add("A23", true, "Tranq", "CatEndgame");
    settings.Add("S18", true, "Bolivia: Kill Sosa", "CatEndgame");
    settings.Add("A56", true, "Contra Band", "CatOptional");
    settings.Add("A59", true, "Gangland", "CatOptional");
    settings.Add("A64", true, "Kidnapped", "CatOptional");
    settings.Add("A80", true, "Baggage Check", "CatOptional");
    settings.Add("FF_0", true, "Girl #1 (Natalia)", "CatOptional");
    settings.Add("FF_1B", true, "Girl #2", "CatOptional");
    settings.Add("FF_2B", true, "Girl #3", "CatOptional");
    settings.Add("FF_3B", true, "Girl #4", "CatOptional");
    settings.Add("FF_4B", true, "Girl #5", "CatOptional");
    settings.Add("T01", true, "Training Map", "CatOptional");
}

init
{
    vars.done_S01c = false;
    vars.done_S03 = false;
    vars.done_S04 = false;
    vars.done_S05 = false;
    vars.done_M_A1B = false;
    vars.done_M_A2B = false;
    vars.done_M_A3B = false;
    vars.done_S14 = false;
    vars.done_M_SHA = false;
    vars.done_S07a = false;
    vars.done_M_B1B = false;
    vars.done_M_B2B = false;
    vars.done_M_B3B = false;
    vars.done_M_B4B = false;
    vars.done_M_SHB = false;
    vars.done_M_D1B = false;
    vars.done_M_D2B = false;
    vars.done_M_D3B = false;
    vars.done_M_D4B = false;
    vars.done_S09 = false;
    vars.done_A51 = false;
    vars.done_A51b = false;
    vars.done_S10 = false;
    vars.done_M_SHD = false;
    vars.done_S11 = false;
    vars.done_S12 = false;
    vars.done_M_C1B = false;
    vars.done_M_C2B = false;
    vars.done_M_C3B = false;
    vars.done_M_C4B = false;
    vars.done_M_C5B = false;
    vars.done_M_SHC = false;
    vars.done_A22 = false;
    vars.done_A23 = false;
    vars.done_S18 = false;
    vars.done_A56 = false;
    vars.done_A59 = false;
    vars.done_A64 = false;
    vars.done_A80 = false;
    vars.done_FF_0 = false;
    vars.done_FF_1B = false;
    vars.done_FF_2B = false;
    vars.done_FF_3B = false;
    vars.done_FF_4B = false;
    vars.done_T01 = false;

    vars.opt_S01c = true;
    vars.opt_S03 = true;
    vars.opt_S04 = true;
    vars.opt_S05 = true;
    vars.opt_M_A1B = true;
    vars.opt_M_A2B = true;
    vars.opt_M_A3B = true;
    vars.opt_S14 = true;
    vars.opt_M_SHA = true;
    vars.opt_S07a = true;
    vars.opt_M_B1B = true;
    vars.opt_M_B2B = true;
    vars.opt_M_B3B = true;
    vars.opt_M_B4B = true;
    vars.opt_M_SHB = true;
    vars.opt_M_D1B = true;
    vars.opt_M_D2B = true;
    vars.opt_M_D3B = true;
    vars.opt_M_D4B = true;
    vars.opt_S09 = true;
    vars.opt_A51 = true;
    vars.opt_A51b = true;
    vars.opt_S10 = true;
    vars.opt_M_SHD = true;
    vars.opt_S11 = true;
    vars.opt_S12 = true;
    vars.opt_M_C1B = true;
    vars.opt_M_C2B = true;
    vars.opt_M_C3B = true;
    vars.opt_M_C4B = true;
    vars.opt_M_C5B = true;
    vars.opt_M_SHC = true;
    vars.opt_A22 = true;
    vars.opt_A23 = true;
    vars.opt_S18 = true;
    vars.opt_A56 = true;
    vars.opt_A59 = true;
    vars.opt_A64 = true;
    vars.opt_A80 = true;
    vars.opt_FF_0 = true;
    vars.opt_FF_1B = true;
    vars.opt_FF_2B = true;
    vars.opt_FF_3B = true;
    vars.opt_FF_4B = true;
    vars.opt_T01 = true;

    vars.settingsLoaded = false;
    vars.onStats        = false;
    vars.lastSucc       = -1;
    vars.hb             = 0;
    vars.hudVisible     = false;
    vars.hudIndex       = -1;
    vars.statsChecks    = 0;
    vars.statsTicks     = 0;

}

update
{
    current.timerPhase = timer.CurrentPhase;

    // Read the per-mission toggles once. If the settings reader is not
    // available, every mission stays enabled (init defaults).
    if (!vars.settingsLoaded)
    {
        vars.settingsLoaded = true;
        try
        {
            vars.opt_S01c = settings["S01c"];
            vars.opt_S03 = settings["S03"];
            vars.opt_S04 = settings["S04"];
            vars.opt_S05 = settings["S05"];
            vars.opt_M_A1B = settings["M_A1B"];
            vars.opt_M_A2B = settings["M_A2B"];
            vars.opt_M_A3B = settings["M_A3B"];
            vars.opt_S14 = settings["S14"];
            vars.opt_M_SHA = settings["M_SHA"];
            vars.opt_S07a = settings["S07a"];
            vars.opt_M_B1B = settings["M_B1B"];
            vars.opt_M_B2B = settings["M_B2B"];
            vars.opt_M_B3B = settings["M_B3B"];
            vars.opt_M_B4B = settings["M_B4B"];
            vars.opt_M_SHB = settings["M_SHB"];
            vars.opt_M_D1B = settings["M_D1B"];
            vars.opt_M_D2B = settings["M_D2B"];
            vars.opt_M_D3B = settings["M_D3B"];
            vars.opt_M_D4B = settings["M_D4B"];
            vars.opt_S09 = settings["S09"];
            vars.opt_A51 = settings["A51"];
            vars.opt_A51b = settings["A51b"];
            vars.opt_S10 = settings["S10"];
            vars.opt_M_SHD = settings["M_SHD"];
            vars.opt_S11 = settings["S11"];
            vars.opt_S12 = settings["S12"];
            vars.opt_M_C1B = settings["M_C1B"];
            vars.opt_M_C2B = settings["M_C2B"];
            vars.opt_M_C3B = settings["M_C3B"];
            vars.opt_M_C4B = settings["M_C4B"];
            vars.opt_M_C5B = settings["M_C5B"];
            vars.opt_M_SHC = settings["M_SHC"];
            vars.opt_A22 = settings["A22"];
            vars.opt_A23 = settings["A23"];
            vars.opt_S18 = settings["S18"];
            vars.opt_A56 = settings["A56"];
            vars.opt_A59 = settings["A59"];
            vars.opt_A64 = settings["A64"];
            vars.opt_A80 = settings["A80"];
            vars.opt_FF_0 = settings["FF_0"];
            vars.opt_FF_1B = settings["FF_1B"];
            vars.opt_FF_2B = settings["FF_2B"];
            vars.opt_FF_3B = settings["FF_3B"];
            vars.opt_FF_4B = settings["FF_4B"];
            vars.opt_T01 = settings["T01"];
        }
        catch
        {
        }
    }

    // Clear per-run state when the timer is reset.
    if (old.timerPhase != current.timerPhase && current.timerPhase == TimerPhase.NotRunning)
    {
        vars.done_S01c = false;
        vars.done_S03 = false;
        vars.done_S04 = false;
        vars.done_S05 = false;
        vars.done_M_A1B = false;
        vars.done_M_A2B = false;
        vars.done_M_A3B = false;
        vars.done_S14 = false;
        vars.done_M_SHA = false;
        vars.done_S07a = false;
        vars.done_M_B1B = false;
        vars.done_M_B2B = false;
        vars.done_M_B3B = false;
        vars.done_M_B4B = false;
        vars.done_M_SHB = false;
        vars.done_M_D1B = false;
        vars.done_M_D2B = false;
        vars.done_M_D3B = false;
        vars.done_M_D4B = false;
        vars.done_S09 = false;
        vars.done_A51 = false;
        vars.done_A51b = false;
        vars.done_S10 = false;
        vars.done_M_SHD = false;
        vars.done_S11 = false;
        vars.done_S12 = false;
        vars.done_M_C1B = false;
        vars.done_M_C2B = false;
        vars.done_M_C3B = false;
        vars.done_M_C4B = false;
        vars.done_M_C5B = false;
        vars.done_M_SHC = false;
        vars.done_A22 = false;
        vars.done_A23 = false;
        vars.done_S18 = false;
        vars.done_A56 = false;
        vars.done_A59 = false;
        vars.done_A64 = false;
        vars.done_A80 = false;
        vars.done_FF_0 = false;
        vars.done_FF_1B = false;
        vars.done_FF_2B = false;
        vars.done_FF_3B = false;
        vars.done_FF_4B = false;
        vars.done_T01 = false;

        vars.settingsLoaded = true;
        vars.onStats        = false;
        vars.lastSucc       = -1;
        vars.hb             = 0;
        vars.hudVisible     = false;
        vars.hudIndex       = -1;
        vars.statsChecks    = 0;
        vars.statsTicks     = 0;
    }

    if (old.paused != current.paused)
    {
    }

    if (old.missionGroup != current.missionGroup)
    {
    }

    // Heartbeat: proves the script is alive and reports the timer phase,
    // because the split block is only called while the timer is running.
    vars.hb = vars.hb + 1;
    if (vars.hb >= 60)
    {
        vars.hb = 0;
    }
}

start
{
    // Start only on The Fall part 1. The group transition is too broad (it also
    // fires when loading any other mission), so use the mission name.
    if (current.missionName == "S01a" && old.missionName != "S01a")
    {
        return true;
    }
}

split
{
    // Mission-complete stats screen: mission ended, game paused.
    if (current.missionGroup == 0 && current.paused == 1)
    {
        if (!vars.onStats)
        {
            vars.onStats = true;
            vars.statsChecks = 0;
            vars.statsTicks = 0;
            vars.hudVisible = false;
        }

        vars.statsTicks = vars.statsTicks + 1;

        // Walk the SimObject table until the mission-complete HUD appears.
        // The object only reaches state 1 once the stats screen is drawn, so
        // keep retrying for several seconds (~4 s at 66 Hz).
        // Quick retries first, then a slow poll: the stats screen stays up
        // until the player accepts, so keep looking without burning CPU.
        int interval = 3;
        if (vars.statsChecks >= 12) { interval = 90; }
        if (!vars.hudVisible && vars.statsTicks >= interval)
        {
            vars.statsChecks = vars.statsChecks + 1;
            vars.statsTicks = 0;
            var table = game.ReadValue<int>((IntPtr)0x80EFAC);
            if (table != 0)
            {
                var rawTable = game.ReadBytes((IntPtr)table, 0x1770 * 8);
                if (rawTable != null && rawTable.Length == 0x1770 * 8)
                {
                    for (int i = 0; i < 0x1770; i++)
                    {
                        var obj = BitConverter.ToInt32(rawTable, i * 8);
                        if (obj == 0) { continue; }
                        var block = game.ReadBytes((IntPtr)obj, 0x24);
                        if (block == null || block.Length != 0x24) { continue; }
                        if (BitConverter.ToInt32(block, 0x20) != 1) { continue; }
                        var namePtr = BitConverter.ToInt32(block, 4);
                        if (namePtr == 0) { continue; }
                        var objName = game.ReadString((IntPtr)namePtr, 24);
                        if (objName != null && objName.StartsWith("EHE_MISSIONCOMPLETE_HUD"))
                        {
                            vars.hudVisible = true;
                            vars.hudIndex = i;
                            break;
                        }
                    }
                }
            }
        }

        // Only a completed mission shows the mission-complete HUD.
        if (vars.hudVisible)
        {
            if (current.missionName == "S01c" && !vars.done_S01c && vars.opt_S01c)
            {
                vars.done_S01c = true;
                return true;
            }
            if (current.missionName == "S03" && !vars.done_S03 && vars.opt_S03)
            {
                vars.done_S03 = true;
                return true;
            }
            if (current.missionName == "S04" && !vars.done_S04 && vars.opt_S04)
            {
                vars.done_S04 = true;
                return true;
            }
            if (current.missionName == "S05" && !vars.done_S05 && vars.opt_S05)
            {
                vars.done_S05 = true;
                return true;
            }
            if (current.missionName == "M_A1B" && !vars.done_M_A1B && vars.opt_M_A1B)
            {
                vars.done_M_A1B = true;
                return true;
            }
            if (current.missionName == "M_A2B" && !vars.done_M_A2B && vars.opt_M_A2B)
            {
                vars.done_M_A2B = true;
                return true;
            }
            if (current.missionName == "M_A3B" && !vars.done_M_A3B && vars.opt_M_A3B)
            {
                vars.done_M_A3B = true;
                return true;
            }
            if (current.missionName == "S14" && !vars.done_S14 && vars.opt_S14)
            {
                vars.done_S14 = true;
                return true;
            }
            if (current.missionName == "M_SHA" && !vars.done_M_SHA && vars.opt_M_SHA)
            {
                vars.done_M_SHA = true;
                return true;
            }
            if (current.missionName == "S07a" && !vars.done_S07a && vars.opt_S07a)
            {
                vars.done_S07a = true;
                return true;
            }
            if (current.missionName == "M_B1B" && !vars.done_M_B1B && vars.opt_M_B1B)
            {
                vars.done_M_B1B = true;
                return true;
            }
            if (current.missionName == "M_B2B" && !vars.done_M_B2B && vars.opt_M_B2B)
            {
                vars.done_M_B2B = true;
                return true;
            }
            if (current.missionName == "M_B3B" && !vars.done_M_B3B && vars.opt_M_B3B)
            {
                vars.done_M_B3B = true;
                return true;
            }
            if (current.missionName == "M_B4B" && !vars.done_M_B4B && vars.opt_M_B4B)
            {
                vars.done_M_B4B = true;
                return true;
            }
            if (current.missionName == "M_SHB" && !vars.done_M_SHB && vars.opt_M_SHB)
            {
                vars.done_M_SHB = true;
                return true;
            }
            if (current.missionName == "M_D1B" && !vars.done_M_D1B && vars.opt_M_D1B)
            {
                vars.done_M_D1B = true;
                return true;
            }
            if (current.missionName == "M_D2B" && !vars.done_M_D2B && vars.opt_M_D2B)
            {
                vars.done_M_D2B = true;
                return true;
            }
            if (current.missionName == "M_D3B" && !vars.done_M_D3B && vars.opt_M_D3B)
            {
                vars.done_M_D3B = true;
                return true;
            }
            if (current.missionName == "M_D4B" && !vars.done_M_D4B && vars.opt_M_D4B)
            {
                vars.done_M_D4B = true;
                return true;
            }
            if (current.missionName == "S09" && !vars.done_S09 && vars.opt_S09)
            {
                vars.done_S09 = true;
                return true;
            }
            if (current.missionName == "A51" && !vars.done_A51 && vars.opt_A51)
            {
                vars.done_A51 = true;
                return true;
            }
            if (current.missionName == "A51b" && !vars.done_A51b && vars.opt_A51b)
            {
                vars.done_A51b = true;
                return true;
            }
            if (current.missionName == "S10" && !vars.done_S10 && vars.opt_S10)
            {
                vars.done_S10 = true;
                return true;
            }
            if (current.missionName == "M_SHD" && !vars.done_M_SHD && vars.opt_M_SHD)
            {
                vars.done_M_SHD = true;
                return true;
            }
            if (current.missionName == "S11" && !vars.done_S11 && vars.opt_S11)
            {
                vars.done_S11 = true;
                return true;
            }
            if (current.missionName == "S12" && !vars.done_S12 && vars.opt_S12)
            {
                vars.done_S12 = true;
                return true;
            }
            if (current.missionName == "M_C1B" && !vars.done_M_C1B && vars.opt_M_C1B)
            {
                vars.done_M_C1B = true;
                return true;
            }
            if (current.missionName == "M_C2B" && !vars.done_M_C2B && vars.opt_M_C2B)
            {
                vars.done_M_C2B = true;
                return true;
            }
            if (current.missionName == "M_C3B" && !vars.done_M_C3B && vars.opt_M_C3B)
            {
                vars.done_M_C3B = true;
                return true;
            }
            if (current.missionName == "M_C4B" && !vars.done_M_C4B && vars.opt_M_C4B)
            {
                vars.done_M_C4B = true;
                return true;
            }
            if (current.missionName == "M_C5B" && !vars.done_M_C5B && vars.opt_M_C5B)
            {
                vars.done_M_C5B = true;
                return true;
            }
            if (current.missionName == "M_SHC" && !vars.done_M_SHC && vars.opt_M_SHC)
            {
                vars.done_M_SHC = true;
                return true;
            }
            if (current.missionName == "A22" && !vars.done_A22 && vars.opt_A22)
            {
                vars.done_A22 = true;
                return true;
            }
            if (current.missionName == "A23" && !vars.done_A23 && vars.opt_A23)
            {
                vars.done_A23 = true;
                return true;
            }
            if (current.missionName == "S18" && !vars.done_S18 && vars.opt_S18)
            {
                vars.done_S18 = true;
                return true;
            }
            if (current.missionName == "A56" && !vars.done_A56 && vars.opt_A56)
            {
                vars.done_A56 = true;
                return true;
            }
            if (current.missionName == "A59" && !vars.done_A59 && vars.opt_A59)
            {
                vars.done_A59 = true;
                return true;
            }
            if (current.missionName == "A64" && !vars.done_A64 && vars.opt_A64)
            {
                vars.done_A64 = true;
                return true;
            }
            if (current.missionName == "A80" && !vars.done_A80 && vars.opt_A80)
            {
                vars.done_A80 = true;
                return true;
            }
            if (current.missionName == "FF_0" && !vars.done_FF_0 && vars.opt_FF_0)
            {
                vars.done_FF_0 = true;
                return true;
            }
            if (current.missionName == "FF_1B" && !vars.done_FF_1B && vars.opt_FF_1B)
            {
                vars.done_FF_1B = true;
                return true;
            }
            if (current.missionName == "FF_2B" && !vars.done_FF_2B && vars.opt_FF_2B)
            {
                vars.done_FF_2B = true;
                return true;
            }
            if (current.missionName == "FF_3B" && !vars.done_FF_3B && vars.opt_FF_3B)
            {
                vars.done_FF_3B = true;
                return true;
            }
            if (current.missionName == "FF_4B" && !vars.done_FF_4B && vars.opt_FF_4B)
            {
                vars.done_FF_4B = true;
                return true;
            }
            if (current.missionName == "T01" && !vars.done_T01 && vars.opt_T01)
            {
                vars.done_T01 = true;
                return true;
            }
        }
    }
    else
    {
        vars.onStats = false;
        vars.hudVisible = false;
        vars.hudIndex = -1;
        vars.statsChecks = 0;
        vars.statsTicks = 0;
    }
}
