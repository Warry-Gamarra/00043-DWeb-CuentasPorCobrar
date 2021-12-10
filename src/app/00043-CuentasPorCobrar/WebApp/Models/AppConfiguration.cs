using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public static class AppConfiguration
    {
        public static string DirectorioCarga()
        {
            return ConfigurationManager.AppSettings["DirectorioCarga"].ToString();
        }
    }
}