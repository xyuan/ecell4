from libcpp.string cimport string
from libcpp cimport bool

from ecell4.types cimport *
from ecell4.shared_ptr cimport shared_ptr
from ecell4.core cimport *

from cpython cimport PyObject

## Cpp_ODEWorld
#  ecell4::ode::ODEWorld
cdef extern from "ecell4/ode/ODEWorld.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODEWorld "ecell4::ode::ODEWorld":
        Cpp_ODEWorld() except +
        Cpp_ODEWorld(Cpp_Real3&) except +
        Cpp_ODEWorld(string&) except +
        # SpaceTraits
        Real& t()
        void set_t(Real&)
        void reset(Cpp_Real3&)
        Cpp_Real3 edge_lengths()
        # CompartmentSpaceTraits
        Real &volume()
        Integer num_molecules(Cpp_Species &)
        Integer num_molecules_exact(Cpp_Species &)
        vector[Cpp_Species] list_species()

        # CompartmentSpace member functions
        void set_volume(Real &)
        void add_molecules(Cpp_Species &sp, Integer &num)
        void add_molecules(Cpp_Species &sp, Integer &num, shared_ptr[Cpp_Shape])
        void remove_molecules(Cpp_Species &sp, Integer &num)
        # Optional members
        Real get_value(Cpp_Species &)
        void set_value(Cpp_Species &sp, Real &num)
        void save(string) except +
        void load(string)
        bool has_species(Cpp_Species &)
        void reserve_species(Cpp_Species &)
        void release_species(Cpp_Species &)
        void bind_to(shared_ptr[Cpp_Model])
        void bind_to(shared_ptr[Cpp_ODENetworkModel])

## ODEWorld
#  a python wrapper for Cpp_ODEWorld
cdef class ODEWorld:
    cdef shared_ptr[Cpp_ODEWorld]* thisptr

cdef ODEWorld ODEWorld_from_Cpp_ODEWorld(shared_ptr[Cpp_ODEWorld] m)

## Following definitions are ODESimulator2 related.

## Cpp_ODERatelaw
cdef extern from "ecell4/ode/ODERatelaw.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODERatelaw "ecell4::ode::ODERatelaw":
        Cpp_ODERatelaw() except +
        bool is_available()

## ODERatelaw
cdef class ODERatelaw:
    #cdef Cpp_ODERatelaw *thisptr
    cdef shared_ptr[Cpp_ODERatelaw] *thisptr

## Cpp_ODERatelawMassAction
cdef extern from "ecell4/ode/ODERatelaw.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODERatelawMassAction "ecell4::ode::ODERatelawMassAction":
        Cpp_ODERatelawMassAction(Real) except +
        bool is_available()
        void set_k(Real)
        Real get_k()

cdef class ODERatelawMassAction:
    #cdef Cpp_ODERatelawMassAction *thisptr
    cdef shared_ptr[Cpp_ODERatelawMassAction] *thisptr

ctypedef void* Python_CallbackFunctype
ctypedef double (*Stepladder_Functype)(
    Python_CallbackFunctype pyfunc, vector[Real], vector[Real], 
    Real volume, Real t, Cpp_ODEReactionRule *)
ctypedef void (*OperateRef_Functype)(void*)

cdef extern from "ecell4/ode/ODERatelaw.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODERatelawCythonCallback " ecell4::ode::ODERatelawCythonCallback":
        Cpp_ODERatelawCythonCallback() except+
        Cpp_ODERatelawCythonCallback(Stepladder_Functype, Python_CallbackFunctype, OperateRef_Functype, OperateRef_Functype) except+
        bool is_available()
        void set_callback_pyfunc(Python_CallbackFunctype)

cdef class ODERatelawCallback:
    cdef shared_ptr[Cpp_ODERatelawCythonCallback] *thisptr
    cdef object pyfunc

## Cpp_ODEReactionRule
cdef extern from "ecell4/ode/ODEReactionRule.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODEReactionRule "ecell4::ode::ODEReactionRule":
        Cpp_ODEReactionRule() except +
        Cpp_ODEReactionRule(Cpp_ReactionRule) except +
        Cpp_ODEReactionRule(Cpp_ODEReactionRule) except +
        Real k()
        void set_k(Real)
        vector[Cpp_Species] reactants()
        vector[Cpp_Species] products()
        vector[Real] reactants_coefficients()
        vector[Real] products_coefficients()

        void add_reactant(Cpp_Species, Real)
        void add_product(Cpp_Species, Real)
        void add_reactant(Cpp_Species)
        void add_product(Cpp_Species)
        void set_reactant_coefficient(int, Real)
        void set_product_coefficient(int, Real)

        void set_ratelaw(shared_ptr[Cpp_ODERatelaw])
        void set_ratelaw(shared_ptr[Cpp_ODERatelawMassAction])
        shared_ptr[Cpp_ODERatelaw] get_ratelaw()
        bool has_ratelaw()
        bool is_massaction()

cdef class ODEReactionRule:
    cdef Cpp_ODEReactionRule *thisptr
    cdef object ratelaw

## Cpp_ODENetworkModel
cdef extern from "ecell4/ode/ODENetworkModel.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODENetworkModel "ecell4::ode::ODENetworkModel":
        Cpp_ODENetworkModel() except +
        Cpp_ODENetworkModel( shared_ptr[Cpp_NetworkModel] ) except +
        void update_model()
        bool has_network_model()
        vector[Cpp_ODEReactionRule] ode_reaction_rules()
        Integer num_reaction_rules()
        void dump_reactions()
        void add_reaction_rule(Cpp_ODEReactionRule)
        void add_reaction_rule(Cpp_ReactionRule)
        vector[Cpp_Species] list_species()

cdef class ODENetworkModel:
    cdef shared_ptr[Cpp_ODENetworkModel] *thisptr

cdef ODENetworkModel ODENetworkModel_from_Cpp_ODENetworkModel(shared_ptr[Cpp_ODENetworkModel] m)

## Cpp_ODESimulator2
cdef extern from "ecell4/ode/ODESimulator2.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODESimulator2 "ecell4::ode::ODESimulator2":
        Cpp_ODESimulator2(shared_ptr[Cpp_ODENetworkModel], shared_ptr[Cpp_ODEWorld]) except+
        Cpp_ODESimulator2(shared_ptr[Cpp_NetworkModel], shared_ptr[Cpp_ODEWorld]) except+
        void initialize()
        void step()
        bool step(Real)
        Real next_time()
        Real t()
        void set_t(Real)
        Real dt()
        void set_dt(Real)
        Integer num_steps()
        Real absolute_tolerance() const
        Real relative_tolerance() const
        void set_absolute_tolerance(Real)
        void set_relative_tolerance(Real)

        shared_ptr[Cpp_ODENetworkModel] model()
        shared_ptr[Cpp_ODEWorld] world()

        void run(Real)
        void run(Real, shared_ptr[Cpp_Observer])
        void run(Real, vector[shared_ptr[Cpp_Observer]])

cdef class ODESimulator2:
    cdef Cpp_ODESimulator2 *thisptr

cdef ODESimulator2 ODESimulator2_from_Cpp_ODESimulator2(Cpp_ODESimulator2* s)

## Cpp_ODEFactory2
#  ecell4::ode::ODEFactory2
cdef extern from "ecell4/ode/ODEFactory2.hpp" namespace "ecell4::ode":
    cdef cppclass Cpp_ODEFactory2 "ecell4::ode::ODEFactory2":
        Cpp_ODEFactory2() except +
        Cpp_ODEWorld* create_world()
        Cpp_ODEWorld* create_world(string)
        Cpp_ODEWorld* create_world(Cpp_Real3&)
        Cpp_ODESimulator2* create_simulator(shared_ptr[Cpp_NetworkModel], shared_ptr[Cpp_ODEWorld])
        Cpp_ODESimulator2* create_simulator(shared_ptr[Cpp_ODENetworkModel], shared_ptr[Cpp_ODEWorld])

## ODEFactory2
#  a python wrapper for Cpp_ODEFactory2
cdef class ODEFactory2:
    cdef Cpp_ODEFactory2* thisptr

