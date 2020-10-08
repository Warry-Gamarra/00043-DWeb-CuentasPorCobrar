using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class PeriodosController : Controller
    {
        // GET: Periodos_Academicos
        public ActionResult Index()
        {
            if (Session["lista_periodo"] == null)
            {
                Session["lista_periodo"] = General.llenar_lista_periodos();
            }

            var lista = Session["lista_periodo"];

            return View(lista);
        }

        // GET: Periodos_Academicos/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: Periodos_Academicos/Create
        [HttpPost]
        public ActionResult Create(PeriodoViewModel model)
        {
            try
            {
                var lista = (List<PeriodoViewModel>)Session["lista_periodo"];

                model.Id = lista.Max(x => x.Id) + 1;

                lista.Add(model);

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
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

                old_model.Descripcion = model.Descripcion;

                old_model.Nro_Cuenta_Corriente = model.Nro_Cuenta_Corriente;

                old_model.Codigo_Banco = model.Codigo_Banco;

                old_model.Fecha_Vencimiento = model.Fecha_Vencimiento;

                old_model.Prioridad = model.Prioridad;

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