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
    public class AlumnosController : ApiController
    {
        public IAlumnoServiceFacade _service;

        public AlumnosController(IAlumnoServiceFacade service)
        {
            _service = service;
        }

        [HttpPost]
        public IHttpActionResult GrabarAlumno(MantenimientoAlumnoModel alumnoModel, int currentUserID)
        {
            ServiceResponse response;

            if (ModelState.IsValid)
            {
                response = _service.GrabarAlumno(alumnoModel, currentUserID);
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

        [HttpPost]
        public IHttpActionResult EditarAlumno(MantenimientoAlumnoModel alumnoModel, int currentUserID)
        {
            ServiceResponse response;

            if (ModelState.IsValid)
            {
                response = _service.EditarAlumno(alumnoModel, currentUserID);
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
        public IHttpActionResult GetAlumnos()
        {
            return Ok(_service.GetAll());
        }

        [HttpGet]
        public IHttpActionResult GetAlumnosPorDocIdent(string codTipDoc, string numDNI)
        {
            return Ok(_service.GetByDocIdent(codTipDoc, numDNI));
        }

        [HttpGet]
        public IHttpActionResult GetByID(string codRc, string codAlu)
        {
            return Ok(_service.GetByID(codRc, codAlu));
        }
    }
}
