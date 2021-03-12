using System;
using System.Configuration;

namespace Domain.UnfvRepositorioClient
{
    public static class UnfvRepositorioClientConfiguration
    {
        public static UriBuilder BaseUrl(string recurso)
        {
            return new UriBuilder(ConfigurationManager.AppSettings["UnfvRepositorioBaseUrl"] + recurso);
        }
    }
}
