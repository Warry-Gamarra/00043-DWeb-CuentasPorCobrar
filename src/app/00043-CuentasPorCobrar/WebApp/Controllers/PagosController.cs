using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApp.Models.Facades;



using System.IO;
using Domain.Helpers;

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

            ViewBag.CurrentYear = DateTime.Now.Year;

            ViewBag.DefaultPeriodo = "15";

            ViewBag.DefaultTipoEstudio = TipoEstudio.Pregrado;

            ViewBag.DefaultFacultad = "";

            return View();
        }

        [Route("operaciones/cargar-pagos")]
        public ActionResult ImportarArchivosPago()
        {
            ViewBag.Title = "Cargar Pagos";
            return View();
        }

        [HttpGet]
        //public ActionResult GenerarArchivosBancos(int cmbAnio, int cmbPeriodo, int tipoAlumno, int nivel)
        public ActionResult GenerarArchivosBancos(int cmbAnio, int cmbPeriodo, TipoEstudio cmbTipoEstudio, string cmbFacultad)
        {
            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago_X_Proceso(cmbAnio, cmbPeriodo, 1, 1);
            var fecha_actual = DateTime.Now;


            MemoryStream memoryStream = new MemoryStream();
            TextWriter tw = new StreamWriter(memoryStream);

            if (cuotas_pago != null && cuotas_pago.Count > 0)
            {
                #region Cabecera
                string cab = String.Format("T{0:D6}{1:D14}{2:D6}{3:D14}{4:yyyyMMdd}{5:D8}",
                    cuotas_pago.Count(),
                    (int)(cuotas_pago.Sum(c => c.I_MontoTotal) * 100),
                    0,
                    0,
                    fecha_actual,
                    0);

                tw.WriteLine(cab);
                #endregion

                #region Detalle
                foreach (var item in cuotas_pago)
                {
                    string det = String.Format("D0001000{0,-20}{1,-40}{2}{3}00000000{4:yyyyMMdd}{5}{6:D14}{0}{7}{8}{9}{4:yyyyMMdd}{10}{11}{12}{13:D14}{14}{6:D14}{15}",
                        item.C_CodAlu.PadLeft(10, '0'),
                        item.T_NombresCompletos,
                        item.I_NroOrden.ToString("D5").PadRight(20, ' '),
                        new String(' ', 20), //Referencia del recibo
                        item.D_FecVencto,
                        "01", //Moneda (01=soles y 02=dolares),
                        (int)(item.I_MontoTotal * 100),
                        item.C_CodRc, //Información adicional
                        item.I_Anio,
                        item.C_Periodo,
                        item.I_ProcesoID.ToString().PadLeft(10, ' '),
                        item.I_MontoTotal.Value.ToString("#.00").PadLeft(10, ' '),
                        new String(' ', 4),
                        0, //Interes moratorio
                        item.N_CodBanco.PadRight(4, '0'),
                        new String('0', 162)
                        );
                    tw.WriteLine(det);
                }
                #endregion

            }

            tw.Flush();
            tw.Close();

            return File(memoryStream.GetBuffer(), "text/plain", "Obligaciones.txt");
        }
    }
}