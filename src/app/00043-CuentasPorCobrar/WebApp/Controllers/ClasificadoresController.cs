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
    [Route("configuracion/clasificadores-de-ingreso/{action}")]
    public class ClasificadoresController : Controller
    {
        public readonly ClasificadorModel _clasificador;
        public readonly SelectModel _selectModels;

        public ClasificadoresController()
        {
            _clasificador = new ClasificadorModel();
            _selectModels = new SelectModel();
        }


        // GET: Clasificadores
        [Route("configuracion/clasificadores-de-ingreso")]
        public ActionResult Index()
        {
            ViewBag.Title = "Clasificadores de Ingreso";
            var model = _clasificador.Find();

            return View(model);
        }

        [Route("configuracion/clasificadores-de-ingreso/nuevo")]
        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.Title = "Agregar Clasificador";
            ViewBag.Anios = new SelectList(_selectModels.GetAnios(2000), "Value", "TextDisplay");

            return PartialView("_RegistrarClasificador", new ClasificadorRegistrarViewModel());
        }

        [Route("configuracion/clasificadores-de-ingreso/editar/{id}")]
        [HttpGet]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Clasificador";
            ViewBag.Anios = new SelectList(_selectModels.GetAnios(2000), "Value", "TextDisplay");

            return PartialView("_RegistrarClasificador", _clasificador.Find(id));
        }

        public JsonResult ChangeState(int RowID, bool B_habilitado)
        {
            var result = _clasificador.ChangeState(RowID, B_habilitado, WebSecurity.CurrentUserId, Url.Action("ChangeState", "Clasificadores"));

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
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
    }
}