﻿using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using Domain.Helpers;
using WebApp.Models.Facades;

namespace WebApp.Models
{
    public class TransferenciaInformacionBCP : ITransferenciaInformacion
    {
        IObligacionServiceFacade _obligacionServiceFacade;
        private DateTime fechaTransmision;

        public TransferenciaInformacionBCP()
        {
            _obligacionServiceFacade = new ObligacionServiceFacade();
            fechaTransmision = DateTime.Now;
        }

        public MemoryStream GenerarInformacionObligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string dependencia)
        {
            var cuotas_pago = _obligacionServiceFacade.Obtener_CuotasPago_X_Proceso(anio, periodo, tipoEstudio, dependencia).Where(x => !x.B_Pagado).ToList();

            var cuentas_bcp = _obligacionServiceFacade.Obtener_CtaDeposito_X_Periodo(anio, periodo, tipoEstudio).Where(x => x.I_EntidadFinanID == Bancos.BCP_ID);

            var cuentas_bcp_split = cuentas_bcp.First().C_NumeroCuenta.Split('-');

            if (cuotas_pago.Count == 0)
            {
                throw new Exception("No hay registros.");
            }

            var memoryStream = new MemoryStream();

            var writer = new StreamWriter(memoryStream, Encoding.UTF8);

            string tipoRegistro = "CC";
            string codigoSucursal = cuentas_bcp_split[0].Substring(0, 3);
            string codigoMoneda = cuentas_bcp_split[2].Substring(0, 1);
            string numeroCuentaEmpresa = cuentas_bcp_split[1].Substring(0, 7);
            string tipoValidacion = "C";
            string nombreEmpresa = "UNIVERSIDAD NACIONAL FEDERICO VILLARREAL";
            int cantidadRegistros = cuotas_pago.Count;
            int montoTotal = (int)(cuotas_pago.Sum(c => c.I_MontoOblig) * 100);
            string tipoArchivoActualizacion = "R";
            string codigoServicio = "000000";
            string fillerCabecera = "";

            string cab = String.Format("{0}{1, -3}{2}{3, -7}{4}{5, -40}{6:yyyyMMdd}{7:D9}{8:D15}{9}{10}{11,157}",
                tipoRegistro,           //0
                codigoSucursal,         //1
                codigoMoneda,           //2
                numeroCuentaEmpresa,    //3
                tipoValidacion,         //4
                nombreEmpresa,          //5
                fechaTransmision,       //6
                cantidadRegistros,      //7
                montoTotal,             //8
                tipoArchivoActualizacion, //9
                codigoServicio,         //10
                fillerCabecera          //11
                );

            writer.WriteLine(cab);

            tipoRegistro = "DD";

            foreach (var item in cuotas_pago)
            {
                string codigoDepositante = item.C_CodAlu.PadLeft(14, '0');
                string nombreDepositante = item.T_NombresCompletos;
                nombreDepositante = StringExtensions.SinCaracteresEspecialies(nombreDepositante.Substring(0, (nombreDepositante.Length < 40 ? nombreDepositante.Length : 40)));
                int montoCupon = (int)(item.I_MontoOblig * 100);
                string informacionRetorno = item.C_CodRc + item.I_ProcesoID.ToString("D6") + montoCupon.ToString("D15");
                int montoMora = 0;
                int montoMinimo = 0;
                string tipoRegistroActualizacion = "A";//M, E
                string nroDocumentoPago = "";
                string nroDocumentoIdentidad = "";
                string fillerDetalle = "";

                string det = String.Format("{0}{1, -3}{2}{3, -7}{4, -14}{5, -40}{6, -30}{7:yyyyMMdd}{8:yyyyMMdd}{9:D15}{10:D15}{11:D9}{12}{13, 20}{14, 16}{15,61}",
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

                writer.WriteLine(det);
            }

            writer.Flush();

            memoryStream.Seek(0, SeekOrigin.Begin);

            return memoryStream;
        }

        public string NombreArchivoGenerado()
        {
            return String.Format("BCP_CREP_VC_{0:yyyyMMdd_HHmm}.txt", fechaTransmision);
        }

        public void RecepcionarInformacionPagos()
        {
            throw new NotImplementedException();
        }
    }
}