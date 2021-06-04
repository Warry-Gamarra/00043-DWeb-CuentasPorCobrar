using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;
using WebMatrix.WebData;

namespace WebApp.Controllers
{
    [Authorize]
    public class ClasificadoresController : Controller
    {
        private readonly ClasificadorModel _clasificador;
        private readonly SelectModel _selectModels;

        public ClasificadoresController()
        {
            _clasificador = new ClasificadorModel();
            _selectModels = new SelectModel();
        }


        // GET: Clasificadores
        [Route("mantenimiento/clasificadores-presupuestales")]
        public ActionResult Index(int? anio)
        {
            anio = anio ?? DateTime.Now.Year;

            ViewBag.Title = "Clasificadores Presupuestales";
            ViewBag.Anios = new SelectList(_selectModels.GetAnios(1990), "Value", "TextDisplay", anio);
            ViewBag.Anio = anio.ToString();

            var model = _clasificador.Find(anio.Value.ToString());

            return View(model);
        }

        [Route("mantenimiento/clasificadores-presupuestales/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Clasificador";

            return PartialView("_RegistrarClasificador", new ClasificadorRegistrarViewModel());
        }

        [Route("mantenimiento/clasificadores-presupuestales/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Clasificador";

            return PartialView("_RegistrarClasificador", _clasificador.Find(id));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(ClasificadorRegistrarViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = _clasificador.Save(model, WebSecurity.CurrentUserId);
            }
            else
            {
                string details = "";
                foreach (ModelState modelState in ViewData.ModelState.Values)
                {
                    foreach (ModelError error in modelState.Errors)
                    {
                        details += error.ErrorMessage + " / ";
                    }
                }

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos. " + details);
            }
            return PartialView("_MsgPartialWR", result);
        }


        [Route("mantenimiento/clasificadores-presupuestales/{anio}/equivalencias/{id}")]
        public ActionResult HabilitarEquivalencias(int id, int anio)
        {
            ViewBag.Title = $"Equivalencias del clasificador para el año { anio.ToString() } ";
            ViewBag.Conceptos = new SelectList(_selectModels.GetCodigoClasificadorConceptos(), "Value", "TextDisplay");

            var clasificador = _clasificador.Find(id);
            if (clasificador == null)
            {
                Response result = new Response()
                {
                    Value = false,
                    Message = "No se obtuvo respuesta para el clasificador seleccionado"
                };

                result.Error(false);
                return PartialView("_MsgModalBodyPartial", result);
            }


            ClasificadorEquivalenciasAnioViewModel model = new ClasificadorEquivalenciasAnioViewModel()
            {
                Anio = anio,
                ClasificadorId = clasificador.Id.Value,
                Clasificador = $"{clasificador.CodClasificador} - {clasificador.Descripcion}",
                EquivalenciasConcepto = _clasificador.FindEquivalencias(clasificador.Id.Value, anio.ToString())
            };

            return PartialView("_RegistrarEquivalenciasAnio", model);
        }

        [HttpPost]
        public ActionResult AgregarConceptoEquivalencia(ClasificadorEquivalenciaViewModel model, int anio)
        {
            var result = _clasificador.SaveEquivalencia(null, model.ClasificadorId, model.ConceptoEquivCod, WebSecurity.CurrentUserId);

            var listadoEquivalenciasModel = _clasificador.FindEquivalencias(model.ClasificadorId, anio.ToString());

            return PartialView("_ListadoEquivalencias", listadoEquivalenciasModel);
        }

        [HttpPost]
        public ActionResult SaveEquivalenciaAnio(int equivalenciaId, string anio, bool enable)
        {
            var result = _clasificador.SaveEquivalenciaAnio(equivalenciaId, anio, enable, WebSecurity.CurrentUserId);

            return Json(result, JsonRequestBehavior.AllowGet);
        }
    }
}