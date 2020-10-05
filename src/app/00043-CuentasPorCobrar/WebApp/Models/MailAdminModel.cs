using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class MailAdminModel
    {
        public List<MailAdminViewModel> Find()
        {
            var result = new List<MailAdminViewModel>();


            return result;
        }

        public MailAdminViewModel Find(int mailId)
        {
            var result = new MailAdminViewModel();


            return result;
        }

        public Response ChangeState(int mailId, bool stateValue, int currentUserId, string returnUrl)
        {
            var result = new Response();


            return result;
        }

        public Response Save(MailAdminViewModel mailAdminViewModel, int currentUserId)
        {
            var result = new Response();


            return result;
        }
    }
}