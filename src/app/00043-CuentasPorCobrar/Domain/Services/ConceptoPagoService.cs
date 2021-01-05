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
        public List<ConceptoPago> Listar_ConceptoPago_Habilitados()
        {
            try
            {
                var lista = USP_S_ConceptoPago.Execute();

                var result = lista.Select(x => new ConceptoPago()
                {
                    I_ConcPagID = x.I_ConcPagID,
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

        public List<ConceptoEntity> Listar_Concepto_Habilitados()
        {
            try
            {
                var lista = TC_Concepto.Find();

                var result = lista.Where(x => x.B_Habilitado).Select(x => new ConceptoEntity()
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

        public Response Grabar_ConceptoPago(ConceptoPagoEntity conceptoPago, SaveOption saveOption)
        {
            ResponseData result;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    var grabarConceptoPago = new USP_I_GrabarConceptoPago()
                    {
                        I_ProcesoID = conceptoPago.I_ProcesoID,
                        I_ConceptoID = conceptoPago.I_ConceptoID,
                        B_Fraccionable = conceptoPago.B_Fraccionable,
                        B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral,
                        B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto,
                        I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                        I_GradoDestino = conceptoPago.I_GradoDestino,
                        I_TipoObligacion = conceptoPago.I_TipoObligacion,
                        T_Clasificador = conceptoPago.T_Clasificador,
                        C_CodTasa = conceptoPago.C_CodTasa,
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

                    result = grabarConceptoPago.Execute();

                    break;

                case SaveOption.Update:
                    var actualizarConceptoPago = new USP_U_ActualizarConceptoPago()
                    {
                        I_ConcPagID = conceptoPago.I_ConcPagID,
                        I_ProcesoID = conceptoPago.I_ProcesoID,
                        I_ConceptoID = conceptoPago.I_ConceptoID,
                        B_Fraccionable = conceptoPago.B_Fraccionable,
                        B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral,
                        B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto,
                        I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                        I_GradoDestino = conceptoPago.I_GradoDestino,
                        I_TipoObligacion = conceptoPago.I_TipoObligacion,
                        T_Clasificador = conceptoPago.T_Clasificador,
                        C_CodTasa = conceptoPago.C_CodTasa,
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

                    result = actualizarConceptoPago.Execute();

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

        public ConceptoPagoEntity Obtener_ConceptoPago(int I_ConcPagID)
        {
            ConceptoPagoEntity result = null;

            try
            {
                var conceptoPago = TI_ConceptoPago.FindByID(I_ConcPagID);

                if (conceptoPago != null)
                {
                    result = new ConceptoPagoEntity()
                    {
                        I_ConcPagID = conceptoPago.I_ConcPagID,
                        I_ProcesoID = conceptoPago.I_ProcesoID,
                        I_ConceptoID = conceptoPago.I_ConceptoID,
                        B_Fraccionable = conceptoPago.B_Fraccionable,
                        B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral,
                        B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto,
                        I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                        I_GradoDestino = conceptoPago.I_GradoDestino,
                        I_TipoObligacion = conceptoPago.I_TipoObligacion,
                        T_Clasificador = conceptoPago.T_Clasificador,
                        C_CodTasa = conceptoPago.C_CodTasa,
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
