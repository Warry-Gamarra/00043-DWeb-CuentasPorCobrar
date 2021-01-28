using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebMatrix.WebData;

namespace WebApp.Controllers
{

    [Authorize]
    public class EstudiantesController : Controller
    {
        private readonly SeleccionarArchivoModel _seleccionarArchivoModel;

        public EstudiantesController()
        {
            _seleccionarArchivoModel = new SeleccionarArchivoModel();
        }

        [Route("operaciones/cargar-estudiantes")]
        public ActionResult Index()
        {
            ViewBag.Title = "Carga de Alumnos";

            return View();
        }

        [Route("operaciones/cargar-aptos-pregrado")]
        public ActionResult CargarArchivoMatriculaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Route("operaciones/cargar-aptos-posgrado")]
        public ActionResult CargarArchivoMatriculaPosgrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado, TipoArchivoAlumno.Matricula);
            return PartialView("_SeleccionarArchivo", model);
        }


        [Route("operaciones/cargar-multas-pregrado")]
        public ActionResult CargarArchivoMultaPregrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Pregrado, TipoArchivoAlumno.MultaNoVotar);
            return PartialView("_SeleccionarArchivo", model);
        }

        [Route("operaciones/cargar-multas-posgrado")]
        public ActionResult CargarArchivoMultaPosgrado()
        {
            var model = _seleccionarArchivoModel.Init(TipoAlumno.Posgrado, TipoArchivoAlumno.MultaNoVotar);
            return PartialView("_SeleccionarArchivo", model);
        }



        [HttpPost]
        [Route("operaciones/cargar-aptos-pregrado")]
        public ActionResult CargarArchivoMatriculaPregrado(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            Response result = new Response();
            result = _seleccionarArchivoModel.CargarAlumnosAptos(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [Route("operaciones/cargar-aptos-posgrado")]
        public ActionResult CargarArchivoMatriculaPosgrado(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            Response result = new Response();
            result = _seleccionarArchivoModel.CargarAlumnosAptos(Server.MapPath("~/Upload/Alumnos/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [Route("operaciones/cargar-multas-pregrado")]
        public ActionResult CargarArchivoMultaPregrado(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            Response result = new Response();
            result = _seleccionarArchivoModel.CargarAlumnosAptos(Server.MapPath("~/Upload/MultaNoVotar/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }


        [HttpPost]
        [Route("operaciones/cargar-multas-posgrado")]
        public ActionResult CargarArchivoMultaPosgrado(HttpPostedFileBase file, TipoAlumno tipoAlumno)
        {
            Response result = new Response();
            result = _seleccionarArchivoModel.CargarAlumnosAptos(Server.MapPath("~/Upload/MultaNoVotar/"), file, tipoAlumno, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }


    }
}