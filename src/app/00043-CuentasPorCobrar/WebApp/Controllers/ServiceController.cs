using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebApp.Models;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class ServiceController : ApiController
    {
        PeriodoModel periodoModel;

        public ServiceController()
        {
            periodoModel = new PeriodoModel();
        }

        // GET: api/Service/5
        public int GetPrioridad(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }

            return periodoModel.Obtener_Prioridad_Tipo_Periodo(id);
        }

        // GET: api/Service/5
        public List<SelectViewModel> GetCuentasDeposito(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }

            var lista = periodoModel.Listar_Combo_CtaDepositoHabilitadas(id);
            
            return lista;
        }
    }
}
