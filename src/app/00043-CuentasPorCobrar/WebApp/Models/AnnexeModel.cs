using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class AnnexeModel
    {
        public List<AnnexeViewModel> Find()
        {
            var result = new List<AnnexeViewModel>();


            return result;
        }

        public List<AnnexeViewModel> Find(int annexeId)
        {
            var result = new List<AnnexeViewModel>();


            return result;
        }

        public Response ChangeState(int annexeId, bool stateValue, string returnUrl)
        {
            var result = new Response();


            return result;
        }

        public Response Save(AnnexeViewModel annexeViewModel, int currentUserId)
        {
            var result = new Response();


            return result;
        }
    }
}