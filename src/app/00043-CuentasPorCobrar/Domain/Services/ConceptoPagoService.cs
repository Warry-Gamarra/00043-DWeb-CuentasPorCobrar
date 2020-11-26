using Data;
using Data.Procedures;
using Data.Tables;
using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public class ConceptoPagoService
    {
        public List<ConceptoPagoPeriodo> Listar_ConceptoPagoPeriodo_Habilitados()
        {
            try
            {
                var lista = USP_S_ConceptoPago_Periodo_Habilitados.Execute();

                var result = lista.Select(x => new ConceptoPagoPeriodo()
                {
                    I_ConcPagPerID = x.I_ConcPagPerID,
                    T_TipoPerDesc = x.T_TipoPerDesc,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    I_Anio = x.I_Anio,
                    I_Periodo = x.I_Periodo,
                    M_Monto = x.M_Monto
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<ConceptoPagoEntity> Listar_ConceptoPago_Habilitados()
        {
            try
            {
                var lista = TC_ConceptoPago.Find();

                var result = lista.Where(x => x.B_Habilitado).Select(x => new ConceptoPagoEntity()
                {
                    I_ConceptoID = x.I_ConceptoID,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    B_Habilitado = x.B_Habilitado,
                    I_UsuarioCre = x.I_UsuarioCre,
                    D_FecCre = x.D_FecCre,
                    I_UsuarioMod = x.I_UsuarioMod,
                    D_FecMod = x.D_FecMod
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<CatalogoOpcionEntity> Listar_CatalogoOpcion_Habilitadas_X_Parametro(DTO.Parametro parametroID)
        {
            try
            {
                var lista = TC_CatalogoOpcion.FindByParametro((int)parametroID);

                var result = lista.Where(x => x.B_Habilitado).Select(x => new CatalogoOpcionEntity()
                {
                    I_OpcionID = x.I_OpcionID,
                    T_OpcionDesc = x.T_OpcionDesc,
                    B_Habilitado = x.B_Habilitado
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public Response Grabar_ConceptoPagoPeriodo(ConceptoPagoPeriodoEntity conceptoPago, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarConceptoPagoPeriodo = new USP_I_GrabarConceptoPago_Periodo()
                    {
                        I_PeriodoID = conceptoPago.I_PeriodoID,
                        I_ConceptoID = conceptoPago.I_ConceptoID,
                        B_Fraccionable = conceptoPago.B_Fraccionable,
                        B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral,
                        B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto,
                        I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                        I_GradoDestino = conceptoPago.I_GradoDestino,
                        I_TipoObligacion = conceptoPago.I_TipoObligacion,
                        T_Clasificador = conceptoPago.T_Clasificador,
                        T_Clasificador5 = conceptoPago.T_Clasificador5,
                        B_Calculado = conceptoPago.B_Calculado,
                        I_Calculado = conceptoPago.I_Calculado,
                        B_AnioPeriodo = conceptoPago.B_AnioPeriodo,
                        I_Anio = conceptoPago.I_Anio,
                        I_Periodo = conceptoPago.I_Periodo,
                        B_Especialidad = conceptoPago.B_Especialidad,
                        C_CodRc = conceptoPago.C_CodRc,
                        B_Dependencia = conceptoPago.B_Dependencia,
                        C_DepCod = conceptoPago.C_DepCod,
                        B_GrupoCodRc = conceptoPago.B_GrupoCodRc,
                        I_GrupoCodRc = conceptoPago.I_GrupoCodRc,
                        B_ModalidadIngreso = conceptoPago.B_ModalidadIngreso,
                        I_ModalidadIngresoID = conceptoPago.I_ModalidadIngresoID,
                        B_ConceptoAgrupa = conceptoPago.B_ConceptoAgrupa,
                        I_ConceptoAgrupaID = conceptoPago.I_ConceptoAgrupaID,
                        B_ConceptoAfecta = conceptoPago.B_ConceptoAfecta,
                        I_ConceptoAfectaID = conceptoPago.I_ConceptoAfectaID,
                        N_NroPagos = conceptoPago.N_NroPagos,
                        B_Porcentaje = conceptoPago.B_Porcentaje,
                        M_Monto = conceptoPago.M_Monto,
                        M_MontoMinimo = conceptoPago.M_MontoMinimo,
                        T_DescripcionLarga = conceptoPago.T_DescripcionLarga,
                        T_Documento = conceptoPago.T_Documento,
                        I_UsuarioCre = conceptoPago.I_UsuarioCre.GetValueOrDefault()
                    };

                    result = grabarConceptoPagoPeriodo.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarConceptoPagoPeriodo = new USP_U_ActualizarConceptoPago_Periodo()
                    {
                        I_ConcPagPerID = conceptoPago.I_ConcPagPerID,
                        I_PeriodoID = conceptoPago.I_PeriodoID,
                        I_ConceptoID = conceptoPago.I_ConceptoID,
                        B_Fraccionable = conceptoPago.B_Fraccionable,
                        B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral,
                        B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto,
                        I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                        I_GradoDestino = conceptoPago.I_GradoDestino,
                        I_TipoObligacion = conceptoPago.I_TipoObligacion,
                        T_Clasificador = conceptoPago.T_Clasificador,
                        T_Clasificador5 = conceptoPago.T_Clasificador5,
                        B_Calculado = conceptoPago.B_Calculado,
                        I_Calculado = conceptoPago.I_Calculado,
                        B_AnioPeriodo = conceptoPago.B_AnioPeriodo,
                        I_Anio = conceptoPago.I_Anio,
                        I_Periodo = conceptoPago.I_Periodo,
                        B_Especialidad = conceptoPago.B_Especialidad,
                        C_CodRc = conceptoPago.C_CodRc,
                        B_Dependencia = conceptoPago.B_Dependencia,
                        C_DepCod = conceptoPago.C_DepCod,
                        B_GrupoCodRc = conceptoPago.B_GrupoCodRc,
                        I_GrupoCodRc = conceptoPago.I_GrupoCodRc,
                        B_ModalidadIngreso = conceptoPago.B_ModalidadIngreso,
                        I_ModalidadIngresoID = conceptoPago.I_ModalidadIngresoID,
                        B_ConceptoAgrupa = conceptoPago.B_ConceptoAgrupa,
                        I_ConceptoAgrupaID = conceptoPago.I_ConceptoAgrupaID,
                        B_ConceptoAfecta = conceptoPago.B_ConceptoAfecta,
                        I_ConceptoAfectaID = conceptoPago.I_ConceptoAfectaID,
                        N_NroPagos = conceptoPago.N_NroPagos,
                        B_Porcentaje = conceptoPago.B_Porcentaje,
                        M_Monto = conceptoPago.M_Monto,
                        M_MontoMinimo = conceptoPago.M_MontoMinimo,
                        T_DescripcionLarga = conceptoPago.T_DescripcionLarga,
                        T_Documento = conceptoPago.T_Documento,
                        B_Habilitado = conceptoPago.B_Habilitado,
                        I_UsuarioMod = conceptoPago.I_UsuarioMod.GetValueOrDefault()
                    };

                    result = actualizarConceptoPagoPeriodo.Execute();

                    break;

                default:
                    result = new ResponseData()
                    {
                        Value = false,
                        Message = "Acción no válida."
                    };

                    break;
            }

            return new Response(result);
        }

        public ConceptoPagoPeriodoEntity Obtener_ConceptoPagoPeriodo(int I_ConcPagPerID)
        {
            ConceptoPagoPeriodoEntity result = null;

            try
            {
                var conceptoPago = TI_ConceptoPago_Periodo.FindByID(I_ConcPagPerID);

                if (conceptoPago != null)
                {
                    result = new ConceptoPagoPeriodoEntity()
                    {
                        I_ConcPagPerID = conceptoPago.I_ConcPagPerID,
                        I_PeriodoID = conceptoPago.I_PeriodoID,
                        I_ConceptoID = conceptoPago.I_ConceptoID,
                        B_Fraccionable = conceptoPago.B_Fraccionable,
                        B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral,
                        B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto,
                        I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                        I_GradoDestino = conceptoPago.I_GradoDestino,
                        I_TipoObligacion = conceptoPago.I_TipoObligacion,
                        T_Clasificador = conceptoPago.T_Clasificador,
                        T_Clasificador5 = conceptoPago.T_Clasificador5,
                        B_Calculado = conceptoPago.B_Calculado,
                        I_Calculado = conceptoPago.I_Calculado,
                        B_AnioPeriodo = conceptoPago.B_AnioPeriodo,
                        I_Anio = conceptoPago.I_Anio,
                        I_Periodo = conceptoPago.I_Periodo,
                        B_Especialidad = conceptoPago.B_Especialidad,
                        C_CodRc = conceptoPago.C_CodRc,
                        B_Dependencia = conceptoPago.B_Dependencia,
                        C_DepCod = conceptoPago.C_DepCod,
                        B_GrupoCodRc = conceptoPago.B_GrupoCodRc,
                        I_GrupoCodRc = conceptoPago.I_GrupoCodRc,
                        B_ModalidadIngreso = conceptoPago.B_ModalidadIngreso,
                        I_ModalidadIngresoID = conceptoPago.I_ModalidadIngresoID,
                        B_ConceptoAgrupa = conceptoPago.B_ConceptoAgrupa,
                        I_ConceptoAgrupaID = conceptoPago.I_ConceptoAgrupaID,
                        B_ConceptoAfecta = conceptoPago.B_ConceptoAfecta,
                        I_ConceptoAfectaID = conceptoPago.I_ConceptoAfectaID,
                        N_NroPagos = conceptoPago.N_NroPagos,
                        B_Porcentaje = conceptoPago.B_Porcentaje,
                        M_Monto = conceptoPago.M_Monto,
                        M_MontoMinimo = conceptoPago.M_MontoMinimo,
                        T_DescripcionLarga = conceptoPago.T_DescripcionLarga,
                        T_Documento = conceptoPago.T_Documento,
                        B_Habilitado = conceptoPago.B_Habilitado.HasValue ? conceptoPago.B_Habilitado.Value : false,
                        I_UsuarioCre = conceptoPago.I_UsuarioCre,
                        I_UsuarioMod = conceptoPago.I_UsuarioMod
                    };
                }
            }
            catch (Exception ex)
            {
                return result;
            }

            return result;
        }
    }
}
