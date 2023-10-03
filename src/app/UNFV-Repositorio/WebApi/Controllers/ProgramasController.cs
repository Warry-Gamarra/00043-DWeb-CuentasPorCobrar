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
    [RoutePrefix("api")]
    public class ProgramasController : ApiController
    {
        public IProgramaServiceFacade _service;

        public ProgramasController(IProgramaServiceFacade service)
        {
            _service = service;
        }

        [HttpGet]
        [Route("programas")]
        public IHttpActionResult GetProgramasUnfv()
        {
            return Ok(_service.GetProgramasUnfv());
        }

        [HttpGet]
        [Route("programas")]
        public IHttpActionResult GetProgramaUnfvByCodProg(string codProg)
        {
            return Ok(_service.GetProgramaUnfvByID(codProg));
        }

        [HttpGet]
        [Route("programas")]
        public IHttpActionResult GetProgramaUnfvByCodRc(string codRc)
        {
            return Ok(_service.GetProgramaUnfvByCodRc(codRc));
        }

        [HttpPost]
        [Route("programas")]
        public IHttpActionResult GrabarProgramaUnfv(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID)
        {
            ServiceResponse response;

            if (ModelState.IsValid)
            {
                response = _service.GrabarProgramaUnfv(programaUnfvModel, currentUserID);
            }
            else
            {
                string errorDetails = "";

                foreach (ModelState modelState in ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        errorDetails += error.ErrorMessage + " / ";
                    }
                }

                response = new ServiceResponse()
                {
                    Success = false,
                    Message = errorDetails
                };
            }

            return Ok(response);
        }

        [HttpPut]
        [Route("programas")]
        public IHttpActionResult EditarProgramaUnfv(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID)
        {
            ServiceResponse response;

            if (ModelState.IsValid)
            {
                response = _service.EditarProgramaUnfv(programaUnfvModel, currentUserID);
            }
            else
            {
                string errorDetails = "";

                foreach (ModelState modelState in ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        errorDetails += error.ErrorMessage + " / ";
                    }
                }

                response = new ServiceResponse()
                {
                    Success = false,
                    Message = errorDetails
                };
            }

            return Ok(response);
        }

        [HttpGet]
        [Route("facultades")]
        public IHttpActionResult GetFacultades()
        {
            return Ok(_service.GetFacultades());
        }

        [HttpGet]
        [Route("facultades/{codFac}")]
        public IHttpActionResult GetFacultadByID(string codFac)
        {
            return Ok(_service.GetFacultadByID(codFac));
        }

        [HttpGet]
        [Route("facultades/{codFac}/escuelas")]
        public IHttpActionResult GetEscuelasByFac(string codFac)
        {
            return Ok(_service.GetEscuelasByFac(codFac));
        }

        [HttpGet]
        [Route("facultades/{codFac}/escuelas/{codEsc}")]
        public IHttpActionResult GetEscuelaByID(string codEsc, string codFac)
        {
            return Ok(_service.GetEscuelaByID(codEsc, codFac));
        }

        [HttpGet]
        [Route("facultades/{codFac}/especialidades")]
        public IHttpActionResult GetEspecialidadesByFac(string codFac)
        {
            return Ok(_service.GetCarrerasProfesionalesByFac(codFac));
        }

        [HttpGet]
        [Route("facultades/{codFac}/escuelas/{codEsc}/especialidades")]
        public IHttpActionResult GetEspecialidadesByEsc(string codEsc, string codFac)
        {
            return Ok(_service.GetCarrerasProfesionalesByEsc(codEsc, codFac));
        }

        [HttpGet]
        [Route("facultades/escuelas/especialidades/{codRc}")]
        public IHttpActionResult GetCarreraProfesionalByID(string codRc)
        {
            return Ok(_service.GetCarreraProfesionalByID(codRc));
        }

        [HttpGet]
        [Route("especialidades")]
        public IHttpActionResult GetCarrerasProfesionales()
        {
            return Ok(_service.GetCarrerasProfesionales());
        }
    }
}
