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
    public class PeriodosController : Controller
    {
        PeriodoModel periodoModel;

        public PeriodosController()
        {
            periodoModel = new PeriodoModel();
        }

        public ActionResult Index()
        {
            ViewBag.Title = "Desc. Cuota de Pago";

            var lista = periodoModel.Listar_Periodos_Habilitados();

            return View(lista);
        }

        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo registro";

            Cargar_Listas();

            ViewBag.Lista_CtaDepoHabilitadas = new List<SelectViewModel>();

            ViewBag.Lista_CtaDepoPeriodo = new List<SelectViewModel>();

            return PartialView("_MantenimientoPeriodo");
        }

        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar registro";

            Cargar_Listas();

            var model = periodoModel.Obtener_Periodo(id);

            ViewBag.Lista_CtaDepoHabilitadas = periodoModel.Listar_Combo_CtaDepositoHabilitadas(model.I_TipoPeriodoID);

            ViewBag.Lista_CtaDepoPeriodo = periodoModel.Listar_Combo_CtasDepoPeriodo(id);

            return PartialView("_MantenimientoPeriodo", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Save(MantenimientoPeriodoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = periodoModel.Grabar_Periodo(model, WebSecurity.CurrentUserId);
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
            ViewBag.Lista_TipoPeriodo = periodoModel.Listar_Combo_TipoPeriodo();

            ViewBag.Lista_Anios = periodoModel.Listar_Anios();
        }
    }
}