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

        public TransferenciaInformacionBcoComercio()
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

            var fecha_actual = DateTime.Now;

            var memoryStream = new MemoryStream();

            var tw = new StreamWriter(memoryStream);

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