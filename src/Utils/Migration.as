namespace Migration
{
    Json::Value RecentlyPlayedJson = Json::FromFile(IO::FromDataFolder("TMXRandom_PlayedMaps.json"));
    Net::HttpRequest@ n_request;
    array<MX::MapInfo@> RecentlyPlayed;
    bool requestError = false;

    array<int> GetLastestPlayedMapsMXId()
    {
        array<int> MXIds;
        if (RecentlyPlayedJson.GetType() != Json::Type::Array) return MXIds;

        for (uint i = 0; i < RecentlyPlayedJson.Length; i++)
        {
            Json::Value MapJson = RecentlyPlayedJson[i];
            int MapId = MapJson["MXID"];
            MXIds.InsertLast(MapId);
        }
        return MXIds;
    }

    void StartRequestMapsInfo(array<int> MXIds)
    {
        array<MX::MapInfo@> Maps;
        string url = PluginSettings::RMC_MX_Url+"/api/maps/get_map_info/multi/";
        string mapIdsStr = "";

        for (uint i = 0; i < MXIds.Length; i++)
        {
            mapIdsStr += tostring(MXIds[i]);
            if (i < MXIds.Length - 1) mapIdsStr += ",";
        }
        @n_request = API::Get(url + mapIdsStr);
    }

    void CheckMXRequest()
    {
        // If there's a request, check if it has finished
        if (n_request !is null && n_request.Finished()) {
            // Parse the response
            string res = n_request.String();
            Log::Trace("Migration::CheckRequest : " + res);
            auto json = Json::Parse(res);

            if (json.GetType() != Json::Type::Array) {
                print("Migration::CheckRequest : Json is not an array");
                requestError = true;
                return;
            }

            if (json.Length < 1) {
                print("Migration::CheckRequest : Error parsing response");
                requestError = true;
                return;
            }

            // Handle the response
            for (uint i = 0; i < json.Length; i++)
            {
                Json::Value MapJson = json[i];
                MX::MapInfo@ Map = MX::MapInfo(MapJson);
                RecentlyPlayed.InsertLast(Map);
            }
            @n_request = null;
        }
    }

    void SaveToDataFile()
    {
        DataManager::InitData(false);
        for (uint i = 0; i < RecentlyPlayed.Length; i++)
        {
            Json::Value MapJson = RecentlyPlayed[i].ToJson();
            DataJson["recentlyPlayed"].Add(MapJson);
        }
        DataManager::SaveData();
        IO::Delete(IO::FromDataFolder("TMXRandom_PlayedMaps.json"));
    }
}