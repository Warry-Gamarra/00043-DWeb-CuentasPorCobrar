using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class ObligacionesController : Controller
    {
        // GET: Obligaciones
        public ActionResult Index()
        {
            if (Session["lista_obligaciones"] == null)
            {
                Session["lista_obligaciones"] = General.llenar_lista_obligaciones();
            }

            var lista = Session["lista_obligaciones"];

            return View(lista);
        }

        // GET: Obligaciones/Create
        public ActionResult Create()
        {
            ViewBag.lista_periodos = General.llenar_lista_periodos();

            ViewBag.Listar_Anios = General.Listar_Anios();

            ViewBag.Listar_Periodos_Academicos = General.Listar_Periodos_Academicos();

            ViewBag.Lista_Vacia = General.Lista_Vacia();

            return View();
        }

        // POST: Obligaciones/Create
        [HttpPost]
        public ActionResult Create(ObligacionViewModel model)
        {
            ViewBag.lista_periodos = General.llenar_lista_periodos();

            ViewBag.Listar_Anios = General.Listar_Anios();

            ViewBag.Listar_Periodos_Academicos = General.Listar_Periodos_Academicos();

            ViewBag.Lista_Vacia = General.Lista_Vacia();

            try
            {
                var lista = (List<ObligacionViewModel>)Session["lista_obligaciones"];

                model.Id = lista.Max(x => x.Id) + 1;

                lista.Add(model);

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: Obligaciones/Edit/5
        public ActionResult Edit(int id)
        {
            var lista = (List<ObligacionViewModel>)Session["lista_obligaciones"];

            var model = lista.FirstOrDefault(x => x.Id == id);

            //ViewBag.lista_periodos = General.llenar_lista_periodos();

            ViewBag.Listar_Anios = General.Listar_Anios();

            ViewBag.Listar_Periodos_Academicos = General.Listar_Periodos_Academicos();

            ViewBag.Lista_Vacia = General.Lista_Vacia();

            return View(model);
        }

        // POST: Obligaciones/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, ObligacionViewModel model)
        {
            //ViewBag.lista_periodos = General.llenar_lista_periodos();

            ViewBag.Listar_Anios = General.Listar_Anios();

            ViewBag.Listar_Periodos_Academicos = General.Listar_Periodos_Academicos();

            ViewBag.Lista_Vacia = General.Lista_Vacia();

            try
            {
                var lista = (List<ObligacionViewModel>)Session["lista_obligaciones"];

                var old_model = lista.FirstOrDefault(x => x.Id == id);

                old_model.Descripcion = model.Descripcion;

                old_model.Fraccionable = model.Fraccionable;

                old_model.Concepto_General = model.Concepto_General;

                old_model.Agrupa_Conceptos = model.Agrupa_Conceptos;

                old_model.Tipo_Alumno = model.Tipo_Alumno;

                old_model.Nivel_Alumno = model.Nivel_Alumno;

                old_model.Tipo_Oblicacion = model.Tipo_Oblicacion;

                old_model.Cuota_Pago = model.Cuota_Pago;

                old_model.Clasificador = model.Clasificador;

                old_model.Clasificador_Cinco_Digitos = model.Clasificador_Cinco_Digitos;

                old_model.Calculado = model.Calculado;

                old_model.Calculado_Opcion = model.Calculado_Opcion;

                old_model.Anio_Periodo = model.Anio_Periodo;

                old_model.Anio = model.Anio;

                old_model.Periodo = model.Periodo;

                old_model.Especialidad = model.Especialidad;

                old_model.Especialidad_Opcion = model.Especialidad_Opcion;

                old_model.Grupo_Cod_Rc = model.Grupo_Cod_Rc;

                old_model.Grupo_Cod_Rc_Opcion = model.Grupo_Cod_Rc_Opcion;

                old_model.Codigo_Ingreso = model.Codigo_Ingreso;

                old_model.Codigo_Ingreso_Opcion = model.Codigo_Ingreso_Opcion;

                old_model.Concepto_Agrupa = model.Concepto_Agrupa;

                old_model.Concepto_Agrupa_Opcion = model.Concepto_Agrupa_Opcion;

                old_model.Concepto_Afecta = model.Concepto_Afecta;

                old_model.Concepto_Afecta_Opcion = model.Concepto_Afecta_Opcion;

                old_model.Nro_Pagos = model.Nro_Pagos;

                old_model.Porcentaje = model.Porcentaje;

                old_model.Monto = model.Monto;

                old_model.Monto_Minimo = model.Monto_Minimo;

                old_model.Descripcion_Larga = model.Descripcion_Larga;

                old_model.Observacion = model.Observacion;

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: Obligaciones/Delete/5
        public ActionResult Delete(int id)
        {
            var lista = (List<ObligacionViewModel>)Session["lista_obligaciones"];

            var model = lista.FirstOrDefault(x => x.Id == id);

            //ViewBag.lista_periodos = General.llenar_lista_periodos();

            ViewBag.Listar_Anios = General.Listar_Anios();

            ViewBag.Listar_Periodos_Academicos = General.Listar_Periodos_Academicos();

            ViewBag.Lista_Vacia = General.Lista_Vacia();

            return View(model);
        }

        // POST: Obligaciones/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                var lista = (List<ObligacionViewModel>)Session["lista_obligaciones"];

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