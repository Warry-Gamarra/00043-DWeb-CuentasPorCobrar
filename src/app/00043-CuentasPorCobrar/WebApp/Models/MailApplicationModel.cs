using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class MailApplicationModel
    {
        public List<MailApplicationViewModel> Find()
        {
            var result = new List<MailApplicationViewModel>();


            return result;
        }

        public MailApplicationViewModel Find(int mailId)
        {
            var result = new MailApplicationViewModel();


            return result;
        }

        public Response ChangeState(int mailId, bool stateValue, int currentUserId, string returnUrl)
        {
            var result = new Response();


            return result;
        }

        public Response Save(MailApplicationViewModel mailApplicationViewModel, int currentUserId)
        {
            var result = new Response();


            return result;
        }
    }
}