using Data;
using Data.Procedures;
using Data.Views;
using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Data.Tables;
using Data.Types;

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

        public Response Generar_Obligaciones_Posgrado(int anio, int periodo, string codGrado, int currentUserID)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPosgrado_X_Ciclo()
            {
                I_Anio = anio,
                I_Periodo = periodo,
                C_CodEsc = codGrado,
                I_UsuarioCre = currentUserID
            };

            result = generarObligaciones.Execute();

            return new Response(result);
        }

        public Response Generar_ObligacionesPregrado_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID)
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

        public Response Generar_ObligacionesPosgrado_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPosgrado_X_Ciclo()
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
        
        public IEnumerable<CuotaPagoDTO> Obtener_CuotasPago_X_Proceso(int anio, int? periodo, TipoEstudio tipoEstudio, string codDependencia)
        {
            IEnumerable<VW_CuotasPago> cuotaPagos;

            switch (tipoEstudio)
            {
                case TipoEstudio.Pregrado:
                    cuotaPagos = VW_CuotasPago.GetPregrado(anio, periodo, codDependencia);
                    break;
                case TipoEstudio.Posgrado:
                    cuotaPagos = VW_CuotasPago.GetPosgrado(anio, codDependencia);
                    break;
                default:
                    throw new InvalidOperationException();
            }

            var result = cuotaPagos.Select(c => Mapper.VW_CuotaPago_To_CuotaPagoDTO(c));

            return result;
        }

        public ImportacionPagoResponse Grabar_Pago_Obligaciones(List<PagoObligacionEntity> dataPagoObligaciones, string observacion, int currentUserID)
        {
            ImportacionPagoResponse result;

            var grabarPago = new USP_I_GrabarPagoObligaciones()
            {
                UserID = currentUserID
            };

            try
            {
                var dataTable = Mapper.PagoObligacionEntity_To_DataTable(dataPagoObligaciones.Where(x => x.B_Correcto).ToList());

                var spResult = grabarPago.Execute(dataTable, observacion, currentUserID).ToList();

                var pagosObservados = dataPagoObligaciones.Where(x => !x.B_Correcto)
                    .Select(x => new DataPagoObligacionesResult() {
                        I_ProcesoID = x.I_ProcesoID,
                        C_CodOperacion = x.C_CodOperacion,
                        C_CodDepositante = x.C_CodAlu,
                        T_NomDepositante = x.T_NomDepositante,
                        C_Referencia = x.C_Referencia,
                        D_FecPago = x.D_FecPago,
                        I_Cantidad = x.I_Cantidad,
                        C_Moneda = x.C_Moneda,
                        I_MontoPago = x.I_MontoPago,
                        I_InteresMora = x.I_InteresMora,
                        T_LugarPago = x.T_LugarPago,
                        I_EntidadFinanID = x.I_EntidadFinanID,
                        I_CtaDepositoID = x.I_CtaDepositoID,
                        B_Success = false,
                        T_ErrorMessage = x.T_ErrorMessage,
                        T_InformacionAdicional = x.T_InformacionAdicional,
                        D_FecVencto = x.D_FecVencto,
                        T_ProcesoDesc = x.T_ProcesoDesc,
                        C_CodigoInterno = x.C_CodigoInterno
                    });

                spResult.AddRange(pagosObservados);

                result = new ImportacionPagoResponse(spResult);
            }
            catch (Exception ex)
            {
                result = new ImportacionPagoResponse()
                {
                    Success = false,
                    Message = ex.Message
                };
            }

            return result;
        }

        public IEnumerable<CtaDepoProceso> Obtener_CtaDeposito_X_Periodo(int anio, int? periodo)
        {
            var ctasDeposito = VW_CtaDepositoProceso.GetCtaDepositoByAnioPeriodo(anio, periodo);

            var result = ctasDeposito.Select(x => Mapper.VW_CtaDepositoProceso_To_CtaDepoProceso(x));

            return result;
        }

        public ObligacionAluCabEntity Obtener_ObligacionAluCab(int obligacionCabID)
        {
            var obligacionAluCab = TR_ObligacionAluCab.FindByID(obligacionCabID);

            var result = Mapper.TR_ObligacionAluCab_To_ObligacionAluCabEntity(obligacionAluCab);

            return result;
        }

        public CuotaPagoDTO Obtener_CuotaPago(int obligacionID)
        {
            var cuotaPago = VW_CuotasPago.FindByObligacionID(obligacionID);

            return (cuotaPago == null) ? null : Mapper.VW_CuotaPago_To_CuotaPagoDTO(cuotaPago);
        }

        public IEnumerable<ObligacionDetalleDTO> Obtener_DetalleObligacion_X_Obligacion(int idObligacion)
        {
            var detalle = VW_DetalleObligaciones.FindByObligacion(idObligacion);

            var result = detalle.Select(d => Mapper.VW_DetalleObligaciones_To_ObligacionDetalleDTO(d));

            return result;
        }

        public ObligacionDetalleDTO Obtener_DetalleObligacion_X_ID(int idObligacionDet)
        {
            var detalle = VW_DetalleObligaciones.FindByID(idObligacionDet);

            var result = detalle == null ? null : Mapper.VW_DetalleObligaciones_To_ObligacionDetalleDTO(detalle);

            return result;
        }

        public Response ActualizarMontoObligaciones(int obligacionAluDetID, decimal monto, int tipoDocumento, string documento, int userID)
        {
            var result = USP_U_ActualizarMontoObligaciones.Execute(obligacionAluDetID, monto, tipoDocumento, documento, userID);

            return new Response(result);
        }

        public Response AnularObligacion(int obligacionID, int currentUserID)
        {
            var result = USP_U_AnularObligacionAlumno.Execute(obligacionID, currentUserID);

            return new Response(result);
        }
    }
}
