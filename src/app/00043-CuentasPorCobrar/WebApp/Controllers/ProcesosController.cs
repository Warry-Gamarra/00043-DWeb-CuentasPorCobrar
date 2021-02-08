using Domain.DTO;
using Domain.Services;
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
    public class ProcesosController : Controller
    {
        ProcesoModel procesoModel;
        private readonly SelectModels _selectModel;

        public ProcesosController()
        {
            procesoModel = new ProcesoModel();
            _selectModel = new SelectModels();
        }


        public ActionResult Index()
        {
            ViewBag.Title = "Procesos y Conceptos";

            var lista = procesoModel.Listar_Procesos();

            return View(lista);
        }

        [Route("configuracion/obligaciones-y-conceptos")]
        public ActionResult Obligaciones()
        {
            ViewBag.Title = "Obligaciones y conceptos";

            var lista = procesoModel.Listar_Procesos();
            ViewBag.Anios = new SelectList(procesoModel.Listar_Anios(), "Value", "TextDisplay", DateTime.Now.Year);
            ViewBag.PeriodosAcademicos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay", 15);

            return View("Obligaciones", lista);
        }


        [Route("configuracion/tasas-y-servicios")]
        public ActionResult Tasas()
        {
            ViewBag.Title = "Tasas y Servicios";

            var lista = procesoModel.Listar_Tasas();
            ViewBag.Anios = new SelectList(procesoModel.Listar_Anios(), "Value", "TextDisplay", DateTime.Now.Year);
            ViewBag.PeriodosAcademicos = new SelectList(_selectModel.GetPeriodosAcademicosCatalogo(), "Value", "TextDisplay", 15);

            return View("Tasas", lista);
        }

        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo registro";

            Cargar_Listas();

            ViewBag.Lista_CtaDepoHabilitadas = new List<SelectViewModel>();

            ViewBag.Lista_CtaDepoProceso = new List<SelectViewModel>();

            return PartialView("_MantenimientoProceso");
        }



        public ActionResult SeleccionarCategorias()
        {
            ViewBag.Title = "Nuevo Proceso";

            ViewBag.Lista_CtaDepoHabilitadas = new List<SelectViewModel>();
            ViewBag.Lista_CtaDepoProceso = new List<SelectViewModel>();

            return PartialView("MantenimientoProgramacion", procesoModel.Listar_Combo_CategoriaPago());
        }




        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar registro";

            Cargar_Listas();

            var model = procesoModel.Obtener_Proceso(id);

            ViewBag.Lista_CtaDepoHabilitadas = procesoModel.Listar_Combo_CtaDepositoHabilitadas(model.I_CatPagoID);

            ViewBag.Lista_CtaDepoProceso = procesoModel.Listar_Combo_CtasDepoProceso(id);

            return PartialView("_MantenimientoProceso", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(MantenimientoProcesoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = procesoModel.Grabar_Proceso(model, WebSecurity.CurrentUserId);
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

                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos" + details);
            }

            return PartialView("_MsgPartialWR", result);
        }

        private void Cargar_Listas()
        {
            ViewBag.Lista_CategoriaPago = procesoModel.Listar_Combo_CategoriaPago();

            ViewBag.Lista_Anios = procesoModel.Listar_Anios();
        }
    }
}