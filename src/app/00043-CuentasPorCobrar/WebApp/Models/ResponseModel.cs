using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public static class ResponseModel
    {
        public static Response Success(this Response response, bool display = true)
        {
            response.Color = "success";
            response.Icon = "fa fa-check-circle";
            response.CurrentID = display ? "display: show;" : "display: none;";

            return response;
        }

        public static Response Success(this Response response, string message, bool display = true)
        {
            response.Color = "success";
            response.Icon = "fa fa-check-circle";
            response.CurrentID = display ? "display: show;" : "display: none;";
            response.Message = message;

            return response;
        }


        public static Response Warning(this Response response, bool display = true)
        {
            response.Color = "warning";
            response.Icon = "fa fa-exclamation-triangle";
            response.CurrentID = display ? "display: show;" : "display: none;";

            return response;
        }

        public static Response Warning(this Response response, string message, bool display = true)
        {
            response.Color = "warning";
            response.Icon = "fa fa-exclamation-triangle";
            response.CurrentID = display ? "display: show;" : "display: none;";
            response.Message = message;

            return response;
        }


        public static Response Error(this Response response, bool display = true)
        {
            response.Color = "danger";
            response.Icon = "fa fa-times-circle";
            response.CurrentID = display ? "display: show;": "display: none;";

            return response;
        }

        public static Response Error(this Response response, string message, bool display = true)
        {
            response.Color = "danger";
            response.Icon = "fa fa-times-circle";
            response.CurrentID = display ? "display: show;": "display: none;";
            response.Message = message;

            return response;
        }


        public static Response Info (this Response response, bool display = true)
        {
            response.Color = "info";
            response.Icon = "fa fa-info-circle";
            response.CurrentID = display ? "display: show;" : "display: none;";

            return response;
        }

        public static Response Info (this Response response, string message, bool display = true)
        {
            response.Color = "info";
            response.Icon = "fa fa-info-circle";
            response.CurrentID = display ? "display: show;" : "display: none;";
            response.Message = message;

            return response;
        }


        public static void Success(ImportacionPagoResponse response, bool display = true)
        {
            response.Color = "success";
            response.Icon = "fa fa-check-circle";
            response.Display = display ? "display: show;" : "display: none;";
        }

        public static void Success(ImportacionPagoResponse response, string message, bool display = true)
        {
            response.Color = "success";
            response.Icon = "fa fa-check-circle";
            response.Display = display ? "display: show;" : "display: none;";
            response.Message = message;
        }


        public static void Warning(ImportacionPagoResponse response, bool display = true)
        {
            response.Color = "warning";
            response.Icon = "fa fa-exclamation-triangle";
            response.Display = display ? "display: show;" : "display: none;";
        }

        public static void Warning(ImportacionPagoResponse response, string message, bool display = true)
        {
            response.Color = "warning";
            response.Icon = "fa fa-exclamation-triangle";
            response.Display = display ? "display: show;" : "display: none;";
            response.Message = message;
        }


        public static void Error(ImportacionPagoResponse response, bool display = true)
        {
            response.Color = "danger";
            response.Icon = "fa fa-times-circle";
            response.Display = display ? "display: show;" : "display: none;";
        }

        public static void Error(ImportacionPagoResponse response, string message, bool display = true)
        {
            response.Color = "danger";
            response.Icon = "fa fa-times-circle";
            response.Display = display ? "display: show;" : "display: none;";
            response.Message = message;
        }


        public static void Info(ImportacionPagoResponse response, bool display = true)
        {
            response.Color = "info";
            response.Icon = "fa fa-info-circle";
            response.Display = display ? "display: show;" : "display: none;";
        }

        public static void Info(ImportacionPagoResponse response, string message, bool display = true)
        {
            response.Color = "info";
            response.Icon = "fa fa-info-circle";
            response.Display = display ? "display: show;" : "display: none;";
            response.Message = message;
        }
    }
}