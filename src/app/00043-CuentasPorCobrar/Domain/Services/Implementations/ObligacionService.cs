using Data;
using Data.Procedures;
using Data.Views;
using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Domain.Services.Implementations
{
    public class ObligacionService : IObligacionService
    {
        public Response Generar_Obligaciones_Pregrado(int anio, int periodo, string codFacultad, int currentUserID)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPregrado_X_Ciclo()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                C_CodFac = codFacultad,
                I_UsuarioCre = currentUserID
            };

            result = generarObligaciones.Execute();

            return new Response(result);
        }

        public Response Generar_Obligaciones_Posgrado(int anio, int periodo, int currentUserID)
        {
            throw new NotImplementedException();
        }

        public Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPregrado_X_Ciclo()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                C_CodAlu = codAlu,
                C_CodRc = codRc,
                I_UsuarioCre = currentUserID
            };

            result = generarObligaciones.Execute();

            return new Response(result);
        }

        public IEnumerable<ObligacionDetalleDTO> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc)
        {
            var detalle = VW_DetalleObligaciones.FindByAlumno(anio, periodo, codAlu, codRc);

            var result = detalle.Select(d => Mapper.VW_DetalleObligaciones_To_ObligacionDetalleDTO(d));

            return result;
        }

        public IEnumerable<CuotaPagoDTO> Obtener_CuotasPago(int anio, int periodo, string codAlu, string codRc)
        {
            var cuotaPagos = VW_CuotasPago.FindByAlumno(anio, periodo, codAlu, codRc);

            var result = cuotaPagos.Select(c => Mapper.VW_CuotaPago_To_CuotaPagoDTO(c));

            return result;
        }
        
        public IEnumerable<CuotaPagoDTO> Obtener_CuotasPago_X_Proceso(int anio, int periodo, TipoEstudio tipoEstudio, string codFac, DateTime? fechaDesde, DateTime? fechaHasta)
        {
            IEnumerable<VW_CuotasPago> cuotaPagos;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    cuotaPagos = VW_CuotasPago.GetPregrado(anio, periodo, codFac, fechaDesde, fechaHasta);
                    break;
                case TipoEstudio.Posgrado:
                    cuotaPagos = VW_CuotasPago.GetPosgrado(anio, periodo, fechaDesde, fechaHasta);
                    break;
                default:
                    throw new InvalidOperationException();
            }

            var result = cuotaPagos.Select(c => Mapper.VW_CuotaPago_To_CuotaPagoDTO(c));

            return result;
        }

        public Response Grabar_Pago_Obligaciones(List<PagoObligacionEntity> dataPagoObligaciones, int currentUserID)
        {
            ResponseData result;

            var grabarPago = new USP_I_GrabarPagoObligaciones()
            {
                D_FecRegistro = DateTime.Now,
                UserID = currentUserID
            };

            var dataTable = Mapper.PagoObligacionEntity_To_DataTable(dataPagoObligaciones);

            result = grabarPago.Execute(dataTable);

            return new Response(result);
        }

        public IEnumerable<CtaDepoProceso> Obtener_CtaDeposito_X_Periodo(int anio, int periodo)
        {
            var ctasDeposito = VW_CtaDepositoProceso.GetCtaDepositoByAnioPeriodo(anio, periodo);

            var result = ctasDeposito.Select(x => Mapper.VW_CtaDepositoProceso_To_CtaDepoProceso(x));

            return result;
        }
    }
}
