using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebApi.Models;

namespace WebApi.Controllers
{
    public class ValuesController : ApiController
    {
        public IServiceFacade _service;

        public ValuesController(IServiceFacade service)
        {
            _service = service;
        }

        public IEnumerable<FacultadModel> GetFacultades()
        {
            return _service.GetFacultades();
        }

        public FacultadModel GetFacultadByID(string codFac)
        {
            return _service.GetFacultadByID(codFac);
        }

        public IEnumerable<EscuelaModel> GetEscuelasByFac(string codFac)
        {
            return _service.GetEscuelasByFac(codFac);
        }

        public EscuelaModel GetEscuelaByID(string codEsc, string codFac)
        {
            return _service.GetEscuelaByID(codEsc, codFac);
        }

        public IEnumerable<EspecialidadModel> GetEspecialidadesByEsc(string codEsc, string codFac)
        {
            return _service.GetEspecialidadesByEsc(codEsc, codFac);
        }

        public EspecialidadModel GetEspecialidadByID(string codEsp, string codEsc, string codFac)
        {
            return _service.GetEspecialidadByID(codEsp, codEsc, codFac);
        }   
    }
}