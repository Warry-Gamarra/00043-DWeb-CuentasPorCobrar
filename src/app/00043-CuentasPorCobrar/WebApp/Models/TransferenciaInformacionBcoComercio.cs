using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using WebApp.Models.Facades;

namespace WebApp.Models
{
    public class TransferenciaInformacionBcoComercio : ITransferenciaInformacion
    {
        IObligacionServiceFacade obligacionServiceFacade;
        private DateTime fecha_actual;

        public TransferenciaInformacionBcoComercio()
        {
            obligacionServiceFacade = new ObligacionServiceFacade();
            fecha_actual = DateTime.Now;
        }

        public byte[] GenerarInformacionObligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string dependencia)
        {
            var cuotas_pago = obligacionServiceFacade.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoEstudio, dependencia);

            if (cuotas_pago.Count == 0)
            {
                throw new Exception("No hay registros.");
            }

            var memoryStream = new MemoryStream();

            var tw = new StreamWriter(memoryStream);

            string identificadorRegistro = "T";
            int cantRegistrosSoles = cuotas_pago.Count();
            int totalSoles = (int)(cuotas_pago.Sum(c => c.I_MontoOblig) * 100);
            int cantRegistrosDolares = 0;
            int totalDolares = 0;
            int fechaVencimiento = 0;

            #region Cabecera
            string cab = String.Format("{0}{1:D6}{2:D14}{3:D6}{4:D14}{5:yyyyMMdd}{6:D8}",
                identificadorRegistro,  //0
                cantRegistrosSoles,     //1
                totalSoles,             //2
                cantRegistrosDolares,   //3
                totalDolares,           //4
                fecha_actual,           //5
                fechaVencimiento        //6
                );

            tw.WriteLine(cab);
            #endregion

            #region Detalle
            foreach (var item in cuotas_pago)
            {
                string identificadorRegistroDetalle = "D";
                string codigoServicio = item.C_CodServicio;
                string codigoSucursal = "000";
                string codigoContrato = item.C_CodAlu.PadLeft(10, '0');
                string nombres = item.T_NombresCompletos;
                string numeroRecibo = item.I_NroOrden.ToString("D5").PadRight(20, ' ');
                string referenciaRecibo = new String(' ', 20);
                string fechaEmision = "00000000";
                string fechaVncto = item.D_FecVencto.ToString("yyyyMMdd");
                string moneda = "01";//Moneda (01=soles y 02=dolares)
                int importeTotal = (int)(item.I_MontoOblig * 100);
                string informacionAdicional = codigoContrato + item.C_CodRc + item.I_Anio.ToString() + item.C_Periodo + fechaVncto +
                    item.I_ProcesoID.ToString().PadLeft(10, ' ') + item.I_MontoOblig.Value.ToString("#.00").PadLeft(10, ' ') + new String(' ', 4);
                int interesMoratorio = 0;
                string codigoConcepto01 = item.N_CodBanco.PadRight(4, '0');
                string otros = new String('0', 162);

                string det = String.Format("{0}{1}{2}{3,-20}{4,-40}{5}{6}{7}{8:yyyyMMdd}{9}{10:D14}{11}{12:D14}{13}{10:D14}{14}",
                    identificadorRegistroDetalle,   //0
                    codigoServicio,                 //1
                    codigoSucursal,                 //2
                    codigoContrato,                 //3
                    nombres,                        //4
                    numeroRecibo,                   //5
                    referenciaRecibo,               //6
                    fechaEmision,                   //7
                    fechaVncto,                     //8
                    moneda,                         //9
                    importeTotal,                   //10
                    informacionAdicional,           //11
                    interesMoratorio,               //12
                    codigoConcepto01,               //13
                    otros                           //14
                    );
                tw.WriteLine(det);
            }
            #endregion
            
            tw.Flush();

            tw.Close();
            
            return memoryStream.GetBuffer();
        }

        public string NombreArchivoGenerado()
        {
            return String.Format("BcoComercio_Obligaciones_{0:yyyy-MM-dd}.txt", fecha_actual);
        }

        public void RecepcionarInformacionPagos()
        {
            throw new NotImplementedException();
        }
    }
}