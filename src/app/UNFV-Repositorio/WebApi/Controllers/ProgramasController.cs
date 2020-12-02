using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.ModelBinding;
using WebApi.Models;

namespace WebApi.Controllers
{
    public class ProgramasController : ApiController
    {
        public IProgramaServiceFacade _service;

        public ProgramasController(IProgramaServiceFacade service)
        {
            _service = service;
        }
        
        [HttpGet]
        public IHttpActionResult GetFacultades()
        {
            return Ok(_service.GetFacultades());
        }

        [HttpGet]
        public IHttpActionResult GetFacultadByID(string codFac)
        {
            return Ok(_service.GetFacultadByID(codFac));
        }

        [HttpGet]
        public IHttpActionResult GetEscuelasByFac(string codFac)
        {
            return Ok(_service.GetEscuelasByFac(codFac));
        }

        [HttpGet]
        public IHttpActionResult GetEscuelaByID(string codEsc, string codFac)
        {
            return Ok(_service.GetEscuelaByID(codEsc, codFac));
        }

        [HttpGet]
        public IHttpActionResult GetEspecialidadesByEsc(string codEsc, string codFac)
        {
            return Ok(_service.GetEspecialidadesByEsc(codEsc, codFac));
        }

        [HttpGet]
        public IHttpActionResult GetEspecialidadByID(string codEsp, string codEsc, string codFac)
        {
            return Ok(_service.GetEspecialidadByID(codEsp, codEsc, codFac));
        }
    }
}