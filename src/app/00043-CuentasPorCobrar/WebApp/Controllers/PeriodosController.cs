using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class PeriodosController : Controller
    {
        PeriodoService periodoService;
        PeriodoModel periodoModel;

        public PeriodosController()
        {
            periodoService = new PeriodoService();
        } 

        // GET: Periodos_Academicos
        public ActionResult Index()
        {
            var lista = periodoService.ListarPeriodos();

            var lista2 = new List<PeriodoViewModel>();

            if (lista != null && lista.Count > 0)
            {
                lista2 = lista.Select(x => new PeriodoViewModel()
                {
                    Id = x.I_PeriodoID,
                    Cuota_Pago_Desc = x.T_CuotaPagoDesc,
                    Anio = x.N_Anio,
                    Fecha_Inicio = x.D_FecIni,
                    Fecha_Vencimiento = x.D_FecFin
                }).ToList();
            }

            return View(lista2);
        }

        // GET: Periodos_Academicos/Create
        public ActionResult Create()
        {
            ViewBag.ListaCuotaPago = periodoService.ListarCuotaPagoHabilitadas();

            return View();
        }

        // POST: Periodos_Academicos/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(NuevoPeriodoViewModel model)
        {
            Response result = new Response();

            if (ModelState.IsValid)
            {
                result = periodoModel.GrabarPeriodo(model);
            }
            else
            {
                ResponseModel.Error(result, "Ha ocurrido un error con el envio de datos");
            }

            return PartialView("_MsgPartialWR", result);
        }

        // GET: Periodos_Academicos/Edit/5
        public ActionResult Edit(int id)
        {
            var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

            var model = lista.FirstOrDefault(x => x.Id == id);

            return View(model);
        }

        // POST: Periodos_Academicos/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, PeriodoViewModel model)
        {
            try
            {
                var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

                var old_model = lista.FirstOrDefault(x => x.Id == id);


                old_model.Fecha_Vencimiento = model.Fecha_Vencimiento;

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: Periodos_Academicos/Delete/5
        public ActionResult Delete(int id)
        {
            var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

            var model = lista.FirstOrDefault(x => x.Id == id);

            return View(model);
        }

        // POST: Periodos_Academicos/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

                lista.RemoveAll(x => x.Id == id);

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }
    }
}