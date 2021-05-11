using Data;
using Data.Procedures;
using Data.Tables;
using Domain.Helpers;
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
        private readonly TC_Concepto _concepto;
        private readonly TI_ConceptoPago _conceptoPago;

        public ConceptoPagoService()
        {
            _concepto = new TC_Concepto();
            _conceptoPago = new TI_ConceptoPago();
        }

        public Response ChangeState(int ConceptoId, bool currentState, int currentUserId)
        {
            _concepto.I_ConceptoID = ConceptoId;
            _concepto.B_Habilitado = !currentState;
            _concepto.D_FecMod = DateTime.Now;

            return new Response(_concepto.ChangeState(currentUserId));
        }

        public Response ChangeStateConceptoProceso(int conceptoPagoId, bool currentState, int currentUserId)
        {
            _conceptoPago.I_ConcPagID = conceptoPagoId;
            _conceptoPago.B_Habilitado = !currentState;
            _conceptoPago.D_FecMod = DateTime.Now;

            return new Response(_conceptoPago.ChangeState(currentUserId));
        }

        public Response Save(ConceptoEntity concepto, int currentUserId, SaveOption saveOption)
        {
            _concepto.I_ConceptoID = concepto.I_ConceptoID;
            _concepto.T_ConceptoDesc = concepto.T_ConceptoDesc;
            _concepto.T_Clasificador = concepto.T_Clasificador;
            _concepto.B_EsPagoMatricula = concepto.B_EsPagoMatricula;
            _concepto.B_EsPagoExtmp = concepto.B_EsPagoExtmp;
            _concepto.B_ConceptoAgrupa = concepto.B_ConceptoAgrupa;
            _concepto.B_Habilitado = concepto.B_Habilitado;
            _concepto.B_Calculado = concepto.B_Calculado;
            _concepto.I_Calculado = concepto.I_Calculado;
            _concepto.I_Monto = concepto.I_Monto;
            _concepto.I_MontoMinimo = concepto.I_MontoMinimo;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _concepto.D_FecCre = DateTime.Now;
                    return new Response(_concepto.Insert(currentUserId));

                case SaveOption.Update:
                    _concepto.D_FecMod = DateTime.Now;
                    return new Response(_concepto.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }

        public ConceptoEntity GetConcepto(int conceptoId)
        {
            var result = new ConceptoEntity();
            TC_Concepto concepto = TC_Concepto.Find(conceptoId);

            result.I_ConceptoID = concepto.I_ConceptoID;
            result.T_ConceptoDesc = concepto.T_ConceptoDesc.ToUpper();
            result.T_Clasificador = concepto.T_Clasificador;
            result.B_EsPagoMatricula = concepto.B_EsPagoMatricula;
            result.B_EsPagoExtmp = concepto.B_EsPagoExtmp;
            result.B_ConceptoAgrupa = concepto.B_ConceptoAgrupa;
            result.B_Calculado = concepto.B_Calculado;
            result.I_Calculado = concepto.I_Calculado;
            result.I_Monto = concepto.I_Monto;
            result.I_MontoMinimo = concepto.I_MontoMinimo;

            return result;
        }

        public List<ConceptoPago> Listar_ConceptoPago_Proceso(int procesoID)
        {
            try
            {
                var lista = USP_S_ConceptoPago.Execute(procesoID);

                var result = lista.Select(x => new ConceptoPago()
                {
                    I_ConcPagID = x.I_ConcPagID.Value,
                    T_CatPagoDesc = x.T_CatPagoDesc,
                    T_ProcesoDesc = x.T_ProcesoDesc,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    I_Anio = x.I_Anio,
                    I_Periodo = x.I_Periodo,
                    M_Monto = x.M_Monto,
                    B_Habilitado = x.B_Habilitado
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<ConceptoPago> Listar_ConceptoPago_Proceso_Habilitados(int procesoID)
        {
            try
            {
                var lista = USP_S_ConceptoPago.Execute(procesoID);

                var result = lista.Where(x => x.B_Habilitado).Select(x => new ConceptoPago()
                {
                    I_ConcPagID = x.I_ConcPagID.Value,
                    T_CatPagoDesc = x.T_CatPagoDesc,
                    T_ProcesoDesc = x.T_ProcesoDesc,
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

        public List<ConceptoPago> Listar_ConceptoPago_TipoObligacion_Habilitados(int? procesoID, TipoObligacion tipoObligacion)
        {
            try
            {
                var lista = USP_S_ConceptoPago.Execute(procesoID, tipoObligacion == TipoObligacion.Matricula ? true : false);

                var result = lista.Select(x => new ConceptoPago()
                {
                    I_ConcPagID = x.I_ConcPagID.Value,
                    T_CatPagoDesc = x.T_CatPagoDesc,
                    T_ProcesoDesc = x.T_ProcesoDesc,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    I_Anio = x.I_Anio,
                    I_Periodo = x.I_Periodo,
                    M_Monto = x.M_Monto,
                    M_MontoMinimo = x.M_MontoMinimo
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
                    T_Clasificador = x.T_Clasificador,
                    B_Calculado = x.B_Calculado,
                    I_Calculado = x.I_Calculado,
                    I_Monto = x.I_Monto,
                    I_MontoMinimo = x.I_MontoMinimo,
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

        public List<ConceptoEntity> Listar_Concepto_All()
        {
            try
            {
                var lista = TC_Concepto.Find();

                var result = lista.Select(x => new ConceptoEntity()
                {
                    I_ConceptoID = x.I_ConceptoID,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    T_Clasificador = x.T_Clasificador,
                    B_Calculado = x.B_Calculado,
                    I_Calculado = x.I_Calculado,
                    I_Monto = x.I_Monto,
                    I_MontoMinimo = x.I_MontoMinimo,
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

        public List<ConceptoEntity> Listar_Concepto(TipoObligacion tipoObligacion)
        {
            try
            {
                var lista = TC_Concepto.Find(tipoObligacion == TipoObligacion.Matricula ? true : false);

                var result = lista.Select(x => new ConceptoEntity()
                {
                    I_ConceptoID = x.I_ConceptoID,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    T_Clasificador = x.T_Clasificador,
                    B_ConceptoAgrupa = x.B_ConceptoAgrupa,
                    B_Habilitado = x.B_Habilitado,
                    I_UsuarioCre = x.I_UsuarioCre,
                    D_FecCre = x.D_FecCre,
                    I_UsuarioMod = x.I_UsuarioMod,
                    D_FecMod = x.D_FecMod,
                    I_Monto = x.I_Monto,
                    I_MontoMinimo = x.I_MontoMinimo,
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<CatalogoOpcionEntity> Listar_CatalogoOpcion_Habilitadas_X_Parametro(Helpers.Parametro parametroID)
        {
            try
            {
                var lista = TC_CatalogoOpcion.FindByParametro((int)parametroID);

                var result = lista.Where(x => x.B_Habilitado).Select(x => new CatalogoOpcionEntity()
                {
                    I_OpcionID = x.I_OpcionID,
                    T_OpcionCod = x.T_OpcionCod,
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
                        T_ConceptoPagoDesc = conceptoPago.T_ConceptoPagoDesc,
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
                        T_ConceptoPagoDesc = conceptoPago.T_ConceptoPagoDesc,
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
                        T_ConceptoPagoDesc = string.IsNullOrEmpty(conceptoPago.T_ConceptoPagoDesc) ? TC_Concepto.Find(conceptoPago.I_ConceptoID).T_ConceptoDesc : conceptoPago.T_ConceptoPagoDesc,
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
