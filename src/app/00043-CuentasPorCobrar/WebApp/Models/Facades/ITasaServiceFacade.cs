using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface ITasaServiceFacade
    {
        IEnumerable<SelectViewModel> listarTasas();
    }
}