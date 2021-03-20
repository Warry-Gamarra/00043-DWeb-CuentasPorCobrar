using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;
using Domain.Helpers;
using WebApp.Models;
using System.Globalization;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    [Authorize]
    public class PagosController : Controller
    {
        IGeneralServiceFacade generalServiceFacade;
        ICatalogoServiceFacade catalogoServiceFacade;
        IObligacionServiceFacade obligacionServiceFacade;
        IAlumnosClientFacade alumnosClientFacade;
        IProgramasClientFacade programasClientFacade;

        public PagosController()
        {
            generalServiceFacade = new GeneralServiceFacade();
            catalogoServiceFacade = new CatalogoServiceFacade();
            obligacionServiceFacade = new ObligacionServiceFacade();
            alumnosClientFacade = new AlumnosClientFacade();
            programasClientFacade = new ProgramasClientFacade();
        }

        // GET: Pagos
        public ActionResult Index()
        {
            ViewBag.Title = "Pagos Registrados";
            return View();
        }


        [Route("operaciones/generar-archivos-pago")]
        public ActionResult ExportarDatosPago()
        {
            ViewBag.Title = "Generar archivos de Pago";

            ViewBag.Anios = generalServiceFacade.Listar_Anios();

            ViewBag.Periodos = catalogoServiceFacade.Listar_Periodos();

            ViewBag.TipoEstudios = generalServiceFacade.Listar_TipoEstudios();

            ViewBag.Facultades = programasClientFacade.GetFacultades(TipoEstudio.Pregrado);

            ViewBag.EntidadesFinancieras = ListaEntidadesFinancieras();

            ViewBag.CurrentYear = DateTime.Now.Year;

            ViewBag.DefaultPeriodo = "15";

            ViewBag.DefaultTipoEstudio = TipoEstudio.Pregrado;

            ViewBag.DefaultFacultad = "";

            return View();
        }

        [HttpGet]
        public ActionResult GenerarArchivosBancos(FiltroEnvioObligacionesModel model)
        {
            try
            {
                var transferenciaInformacion = TransferenciaInformacionFactory.Get(model.I_EntidadFinanciera);

                var memoryStream = transferenciaInformacion.GenerarInformacionObligaciones(model.I_Anio, model.I_Periodo, model.E_TipoEstudio, model.T_Facultad, model.D_FechaDesde, model.D_FechaHasta);

                return File(memoryStream, "text/plain", "Obligaciones.txt");
            }
            catch (Exception ex)
            {
                //return View("generar-archivos-pago", model);
                return RedirectToAction("generar-archivos-pago", "operaciones");
            }
        }

        [Route("operaciones/cargar-pagos")]
        public ActionResult ImportarArchivosPago()
        {
            ViewBag.Title = "Cargar Pagos";
            return View();
        }

        private IEnumerable<SelectViewModel> ListaEntidadesFinancieras()
        {
            var listaEntidades = new List<SelectViewModel>();

            listaEntidades.Add(new SelectViewModel() { Value = "1", TextDisplay = "BANCO DE COMERCIO" });

            listaEntidades.Add(new SelectViewModel() { Value = "2", TextDisplay = "BANCO DE CRÉDITO" });

            return listaEntidades;
        }
    }
}