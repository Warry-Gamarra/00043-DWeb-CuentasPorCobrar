using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using Domain.Helpers;
using WebApp.Models.Facades;

namespace WebApp.Models
{
    public class TransferenciaInformacionBCP : ITransferenciaInformacion
    {
        IObligacionServiceFacade obligacionServiceFacade;

        public TransferenciaInformacionBCP()
        {
            obligacionServiceFacade = new ObligacionServiceFacade();
        }

        public byte[] GenerarInformacionObligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string facultad, DateTime? fechaDesde, DateTime? fechaHasta)
        {
            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoEstudio, facultad, fechaDesde, fechaHasta);

            if (cuotas_pago.Count == 0)
            {
                throw new Exception("No hay registros.");
            }

            var memoryStream = new MemoryStream();

            var tw = new StreamWriter(memoryStream);

            string tipoRegistro = "CC";
            string codigoSucursal = "123";
            string codigoMoneda = "0";
            string numeroCuentaEmpresa = "1234567";
            string tipoValidacion = "C";
            string nombreEmpresa = "UNFV";
            DateTime fechaTransmision = DateTime.Now;
            int cantidadRegistros = cuotas_pago.Count;
            string montoTotal = cuotas_pago.Sum(c => c.I_MontoTotal).Value.ToString("#,000");
            string tipoArchivo = "R";//A
            string codigoServicio = "";
            string filler = "";

            string cab = String.Format("{0, 2}{1, -3}{2, 1}{3, -7}{4, 1}{5, -40}{6:yyyyMMdd}{7:D9}{8, 15}{9, 1}{10, 6}{11, 157}",
                tipoRegistro, codigoSucursal, codigoMoneda, numeroCuentaEmpresa, tipoValidacion, nombreEmpresa, 
                fechaTransmision, cantidadRegistros, montoTotal, tipoArchivo, codigoServicio, filler);

            tw.WriteLine(cab);

            tw.Flush();

            tw.Close();

            return memoryStream.GetBuffer();
        }

        public void RecepcionarInformacionPagos()
        {
            throw new NotImplementedException();
        }
    }
}