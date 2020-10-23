using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebApp.Models;

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
            return periodoModel.Obtener_Prioridad_Tipo_Periodo(id);
        }
    }
}
