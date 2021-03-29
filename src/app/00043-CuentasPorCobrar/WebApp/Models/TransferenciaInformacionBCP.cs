using System;
using System.Collections.Generic;
using System.Globalization;
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
            string montoTotal = BCPDecimalFormat(cuotas_pago.Sum(c => c.I_MontoTotal));
            string tipoArchivo = "R";//A
            string codigoServicio = "";
            string filler = "";

            string cab = String.Format("{0}{1, -3}{2}{3, -7}{4}{5, -40}{6:yyyyMMdd}{7:D9}{8, 15}{9, 1}{10, 6}{11, 157}",
                tipoRegistro,           //0
                codigoSucursal,         //1
                codigoMoneda,           //2
                numeroCuentaEmpresa,    //3
                tipoValidacion,         //4
                nombreEmpresa,          //5
                fechaTransmision,       //6
                cantidadRegistros,      //7
                montoTotal,             //8
                tipoArchivo,            //9
                codigoServicio,         //10
                filler                  //11
                );

            tw.WriteLine(cab);

            tipoRegistro = "DD";

            foreach (var item in cuotas_pago)
            {
                string codigoDepositante = item.C_CodAlu.PadLeft(14, '0');
                string nombreDepositante = (item.T_Nombre.Trim() + " " + (item.T_ApePaterno.Trim() + " " + item.T_ApeMaterno).Trim());
                nombreDepositante = nombreDepositante.Substring(0, (nombreDepositante.Length < 40 ? nombreDepositante.Length : 40));
                string informacionRetorno = "INFORMACION DE RETORNO";
                string montoCupon = BCPDecimalFormat(item.I_MontoTotal).PadLeft(15, '0');
                string montoMora = BCPDecimalFormat(0).PadLeft(15, '0');
                string montoMinimo = BCPDecimalFormat(0).PadLeft(9, '0');
                string tipoRegistroActualizacion = "A";//M, E
                string nroDocumentoPago = "";
                string nroDocumentoIdentidad = "";
                string fillerDetalle = "";

                string det = String.Format("{0}{1, -3}{2}{3, -7}{4, -14}{5, -40}{6, -30}{7:yyyyMMdd}{8:yyyyMMdd}{9}{10}{11}{12}{13, 20}{14, 16}{15, 61}",
                    tipoRegistro,               //0
                    codigoSucursal,             //1
                    codigoMoneda,               //2
                    numeroCuentaEmpresa,        //3
                    codigoDepositante,          //4
                    nombreDepositante,          //5
                    informacionRetorno,         //6
                    fechaTransmision,           //7
                    item.D_FecVencto,           //8
                    montoCupon,                 //9
                    montoMora,                  //10
                    montoMinimo,                //11
                    tipoRegistroActualizacion,  //12
                    nroDocumentoPago,           //13
                    nroDocumentoIdentidad,      //14
                    fillerDetalle               //15
                    );

                tw.WriteLine(det);
            }

            tw.Flush();

            tw.Close();

            return memoryStream.GetBuffer();
        }

        public void RecepcionarInformacionPagos()
        {
            throw new NotImplementedException();
        }

        private string BCPDecimalFormat(decimal? value)
        {
            value = value ?? 0;
            return value.Value.ToString("F3", CultureInfo.CreateSpecificCulture("es-ES"));
        }
    }
}