using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class CategoriaPagoModel
    {
        //private readonly ICategoriaPago _categoriaPago;

        public CategoriaPagoModel()
        {
            //_categoriaPago = new CategoriaPago();
        }

        public List<CategoriaPagoViewModel> Find()
        {
            return new List<CategoriaPagoViewModel>();
        }

        public CategoriaPagoRegistroViewModel Find(int categoriaPagoID)
        {
            return new CategoriaPagoRegistroViewModel();
        }

        public Response Save(CategoriaPagoRegistroViewModel model, int currentId)
        {
            return new Response(); ;
        }

        public Response ChangeState(int categoriaPagoID, bool currentState, int currentUserId, string returnUrl)
        {
            return new Response();
        }

    }
}