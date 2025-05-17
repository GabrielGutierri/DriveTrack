using Newtonsoft.Json;

namespace DriveTrackAPI.Model
{
    public class CometResponse
    {
        [JsonProperty("contextResponses")]
        public List<ContextResponse> ContextResponses { get; set; }
    }

    public class ContextResponse
    {
        [JsonProperty("contextElement")]
        public ContextElement ContextElement { get; set; }
    }

    public class ContextElement
    {
        [JsonProperty("attributes")]
        public List<CometAttribute> Attributes { get; set; }

        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("type")]
        public string Type { get; set; }
    }

    public class CometAttribute
    {
        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("values")]
        public List<CometValue> Values { get; set; }
    }

    public class CometValue
    {
        [JsonProperty("_id")]
        public string Id { get; set; }

        [JsonProperty("recvTime")]
        public string RecvTime { get; set; }

        [JsonProperty("attrName")]
        public string AttrName { get; set; }

        [JsonProperty("attrType")]
        public string AttrType { get; set; }

        [JsonProperty("attrValue")]
        public string AttrValue { get; set; }
    }
}
